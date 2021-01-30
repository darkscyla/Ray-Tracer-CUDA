// --- Internal Includes  ---
#include "rt_utils.cuh"
#include "vec3.cuh"
#include "Ray.cuh"
#include "hittable.cuh"
#include "camera.cuh"
#include "scene_selector.cuh"
#include "image_wrapper.cuh"

// --- CUDA Includes ---
#include <device_launch_parameters.h>
#include <curand_kernel.h>

// --- OpenCV Includes ---
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

// --- Parallel Includes ---
#include <omp.h>

using namespace ray_tracer;

RT_DEVICE Color color(const Ray& ray, const Color& background, Hittable** world, const size_t depth, curandState_t* rand_state)
{
    auto cur_ray = ray;
    auto cur_attenuation = Vec3{ 1.0f, 1.0f, 1.0f };
    auto gathered_light = Color({0.0f, 0.0f, 0.0f});
    HitRecord rec;

    for (size_t i = 0; i < depth; ++i)
    {
        if ((*world)->hit(cur_ray, 0.001f, kInfinity, rec))
        {
            Ray scattered;
            Color attenuation;
            const auto emitted = rec.material->emitted(rec.hit_point, rec.u, rec.v);

            if (rec.material->scatter(rand_state, cur_ray, rec, attenuation, scattered))
            {
                gathered_light += emitted * cur_attenuation;
                cur_attenuation *= attenuation;
                cur_ray = scattered;
            }
            else
            {
                return gathered_light + (emitted * cur_attenuation);
            }
        }
        else
        {
            return gathered_light + (background * cur_attenuation);
        }
    }

    return { 0.0f, 0.0f, 0.0f };
}

RT_GLOBAL void render(Vec3* fb, const size_t max_x, const size_t max_y,
    const size_t samples, Camera** camera, Hittable** world, curandState_t* rand_state)
{
    const auto i = threadIdx.x + blockIdx.x * blockDim.x;
    const auto j = threadIdx.y + blockIdx.y * blockDim.y;

    if (i >= max_x || j >= max_y)
    {
        return;
    }

    const auto pixel_index = j * max_x + i;
    auto local_rand_state = rand_state[pixel_index];

    Vec3 col{ 0.0f, 0.0f, 0.0f };

    for (size_t k = 0; k < samples; ++k)
    {
        const auto u = static_cast<float>(i + curand_uniform(&local_rand_state)) / max_x;
        const auto v = static_cast<float>(j + curand_uniform(&local_rand_state)) / max_y;

        col += color((*camera)->get_ray(&local_rand_state, u, v), 
            (*camera)->background(), world, (*camera)->depth(), &local_rand_state);
    }

    const auto scale = 1.0f / static_cast<float>(samples);

    fb[pixel_index] = Color {
        std::cbrt(scale * col[0]),
        std::cbrt(scale * col[1]),
        std::cbrt(scale * col[2])
    };
    color_correct(fb[pixel_index]);
}

RT_GLOBAL void destroy_world(Hittable** d_world, Camera** d_camera)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        delete* (d_world);
        delete* (d_camera);
    }
}

RT_GLOBAL void setup_rand(curandState_t* rand_state, const size_t max_x, const size_t max_y)
{
    const auto i = threadIdx.x + blockIdx.x * blockDim.x;
    const auto j = threadIdx.y + blockIdx.y * blockDim.y;

    if (i >= max_x || j >= max_y)
    {
        return;
    }

    const auto pixel_index = j * max_x + i;

    curand_init(1984 + pixel_index, 0, 0, &rand_state[pixel_index]);
}

int main()
{
    //constexpr auto aspect_ratio = 1.0;
    constexpr auto aspect_ratio = 16.0f / 9.0f;
    constexpr size_t image_height = 1080;
    //constexpr size_t image_height = 10;
    constexpr auto image_width = static_cast<size_t>(image_height * aspect_ratio);
    constexpr size_t samples_per_pixel = 1000;
    const size_t scene_id = 9;

    const auto pixels = image_width * image_height;

    Vec3* vb;
    CUDA_CHECK_ERRORS(cudaMallocManaged(&vb, pixels * sizeof(Vec3)));

    // Create the world and camera
    Hittable** d_world;
    CUDA_CHECK_ERRORS(cudaMalloc(&d_world, sizeof(Hittable*)));

    Camera** d_camera;
    CUDA_CHECK_ERRORS(cudaMalloc(&d_camera, sizeof(Camera*)));

    const size_t num_textures = 2;
    ImageWrapper h_textures[num_textures] = {
        ImageWrapper("resources/earth.jpg"),
        ImageWrapper("resources/abs_final.png")
    };

    ImageWrapper* d_textures;
    CUDA_CHECK_ERRORS(cudaMalloc(&d_textures, num_textures * sizeof(ImageWrapper)));
    cudaMemcpy(d_textures, h_textures, num_textures * sizeof(ImageWrapper), cudaMemcpyHostToDevice);

    // For creating the world, we use BVH and need to increase the stack size
    size_t size;
    cudaDeviceGetLimit(&size, cudaLimitStackSize);
    cudaDeviceSetLimit(cudaLimitStackSize, 8 * size);

    select_scene<< <1, 1 >> >(scene_id, d_textures, d_world, d_camera, aspect_ratio);
    CUDA_CHECK_ERRORS(cudaGetLastError());
    CUDA_CHECK_ERRORS(cudaDeviceSynchronize());

    //// Restore the original stack size
    //cudaDeviceSetLimit(cudaLimitStackSize, size);

    const size_t tx = 16;
    const size_t ty = 16;

    dim3 blocks{ image_width / tx + 1, image_height / ty + 1 };
    dim3 threads{ tx, ty };

    // Setup the CUDA rand stuff
    curandState_t* d_rand_state;
    CUDA_CHECK_ERRORS(cudaMalloc(&d_rand_state, pixels * sizeof(curandState_t)));

    std::cout << "CUDA: Generating random states" << std::endl;
    setup_rand << <blocks, threads >> > (d_rand_state, image_width, image_height);
    CUDA_CHECK_ERRORS(cudaGetLastError());
    CUDA_CHECK_ERRORS(cudaDeviceSynchronize());

    // Render the image
    const auto start_time = std::chrono::high_resolution_clock::now();

    std::cout << "CUDA: Rendering..." << std::endl;
    render << <blocks, threads >> > (vb, image_width, image_height, 
        samples_per_pixel, d_camera, d_world, d_rand_state);

    CUDA_CHECK_ERRORS(cudaGetLastError());
    CUDA_CHECK_ERRORS(cudaDeviceSynchronize());

    const auto time_elapsed = std::chrono::duration_cast<std::chrono::seconds>(
        std::chrono::high_resolution_clock::now() - start_time).count();
    std::cout << "GPU took: " << time_elapsed << " secs..." << std::endl;

    cv::Mat image = cv::Mat::zeros(image_height, image_width, CV_8UC3);

    #pragma omp parallel for
    for (auto i = 0; i < image_width; ++i)
    {
        for (auto j = 0; j < image_height; ++j)
        {
            // OpenCV uses BGR
            const auto pixel_index = j * image_width + i;
            image.at<cv::Vec3b>(cv::Point(static_cast<int>(i), static_cast<int>(j))) = cv::Vec3b{
                static_cast<uint8_t>(255.99 * vb[pixel_index][2]),
                static_cast<uint8_t>(255.99 * vb[pixel_index][1]),
                static_cast<uint8_t>(255.99 * vb[pixel_index][0])
            };
        }
    }

    cv::flip(image, image, 0);
    cv::imwrite("result.png", image);

    destroy_world << <1, 1 >> > (d_world, d_camera);
    CUDA_CHECK_ERRORS(cudaGetLastError());
    CUDA_CHECK_ERRORS(cudaDeviceSynchronize());

    CUDA_CHECK_ERRORS(cudaFree(d_textures));
    CUDA_CHECK_ERRORS(cudaFree(d_camera));
    CUDA_CHECK_ERRORS(cudaFree(d_world));
    CUDA_CHECK_ERRORS(cudaFree(d_rand_state));
    CUDA_CHECK_ERRORS(cudaFree(vb));

    // Manually cleanup the textures that reside in device memory
    for(size_t index = 0; index < num_textures; ++index)
    {
        h_textures[index].release_device_data();
    }

    CUDA_CHECK_ERRORS(cudaDeviceReset());

    return 0;
}
