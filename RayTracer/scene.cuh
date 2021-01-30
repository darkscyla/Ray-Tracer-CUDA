#pragma once

// --- Internal Includes ---
#include "vec3.cuh"
#include "sphere.cuh"
#include "lambert.cuh"
#include "metal.cuh"
#include "dielectric.cuh"
#include "hittable_list.cuh"
#include "checker_texture.cuh"
#include "noise_texture.cuh"
#include "image_texture.cuh"
#include "diffuse_light.cuh"
#include "colored_noise_texture.cuh"
#include "xy_rect.cuh"
#include "yz_rect.cuh"
#include "xz_rect.cuh"
#include "box.cuh"
#include "rotate_y.cuh"
#include "translate.cuh"
#include "isotropic.cuh"
#include "constant_volume.cuh"
#include "bvh.cuh"
#include "sphere_moving.cuh"

// --- CUDA Includes ---
#include <curand_kernel.h>

namespace ray_tracer {

#define RND (curand_uniform(&local_rand_state))

RT_DEVICE inline void random_scene(Hittable** d_world)
{
    const size_t dx = 22;
    const size_t dy = 22;

    // Setup the random number generation
    curandState_t local_rand_state;
    curand_init(1984, 0, 0, &local_rand_state);

    // Reserve memory for the hittable list objects
    const auto d_list = new Hittable * [dx * dy + 4];

    size_t index = 0;

    for (auto a = -11; a < 11; a++)
    {
        for (auto b = -11; b < 11; b++)
        {
            const auto choose_mat = random_unit(&local_rand_state);
            Point3 center{ a + 0.9f * random_unit(&local_rand_state), 0.2f, b + 0.9f * random_unit(&local_rand_state) };

            if (choose_mat < 0.8f)
            {
                d_list[index++] = new Sphere(center, 0.2,
                    new Lambert(Vec3(RND * RND, RND * RND, RND * RND)));
            }
            else if (choose_mat < 0.95f) {
                d_list[index++] = new Sphere(center, 0.2,
                    new Metal(Vec3(0.5f * (1.0f + RND), 0.5f * (1.0f + RND), 0.5f * (1.0f + RND)), 0.5f * RND));
            }
            else
            {
                d_list[index++] = new Sphere(center, 0.2, new Dielectric({ 1.0f, 1.0f, 1.0f }, 1.5f));
            }
        }
    }

    d_list[index++] = new Sphere(Vec3(0, 1, 0), 1.0, new Dielectric({ 1.0f, 1.0f, 1.0f }, 1.5));
    d_list[index++] = new Sphere(Vec3(-4, 1, 0), 1.0, new Lambert(Vec3(0.4, 0.2, 0.1)));
    d_list[index++] = new Sphere(Vec3(4, 1, 0), 1.0, new Metal(Vec3(0.7, 0.6, 0.5), 0.0));
    d_list[index++] = new Sphere(Vec3(0, -1000.0, -1), 1000, new Lambert(
        new CheckerTexture({ 0.2f, 0.3f, 0.1f }, { 0.9f, 0.9f, 0.9f })
    ));
    // Hittable List frees up the memory
    *d_world = new HittableList(d_list, index);
}

RT_DEVICE inline void two_spheres(Hittable** d_world)
{
    const auto d_list = new Hittable * [2];

    d_list[0] = new Sphere(Point3{ 0, -10, 0 }, 10.0, new Lambert(
        new CheckerTexture(Color{ 0.2, 0.3, 0.1 }, Color{ 0.9, 0.9, 0.9 })
    ));
    d_list[1] = new Sphere(Point3{ 0, 10, 0 }, 10.0, new Lambert(
        new CheckerTexture(Color{ 0.2, 0.3, 0.1 }, Color{ 0.9, 0.9, 0.9 })
    ));

    *d_world = new HittableList(d_list, 2);
}

RT_DEVICE inline void two_perlin_spheres(Hittable** d_world)
{
    // Setup the random number generation
    curandState_t local_rand_state;
    curand_init(1984, 0, 0, &local_rand_state);

    const auto d_list = new Hittable* [2];

    d_list[0] = new Sphere({ 0.0f, -1000.0f, 0.0f }, 1000.0f, new Lambert(
        new NoiseTexture(4, &local_rand_state)
    ));
    d_list[1] = new Sphere({ 0.0f, 2.0f, 0.0f }, 2.0f, new Lambert(
        new NoiseTexture(4, &local_rand_state)
    ));

    *d_world = new HittableList(d_list, 2);
}

RT_DEVICE inline void earth(Hittable** d_world, ImageWrapper* images)
{
    const auto d_list = new Hittable * [1];

    d_list[0] = new Sphere({ 0.0f, 0.0f, 0.0f }, 2.0f, new Lambert(
        new ImageTexture(&images[0])
    ));

    *d_world = new HittableList(d_list, 1);
}

RT_DEVICE inline void simple_light(Hittable** d_world)
{
    // Setup the random number generation
    curandState_t local_rand_state;
    curand_init(1984, 0, 0, &local_rand_state);

    const auto d_list = new Hittable * [3];

    d_list[0] = new Sphere({ 0.0f, -1000.0f, 0.0f }, 1000.0f, new Lambert(
        new NoiseTexture(4.0f, &local_rand_state)
    ));
    d_list[1] = new Sphere({ 0.0f, 2.0f, 0.0f }, 2.0f, new Lambert(
        new  ColoredNoiseTexture(4.0f, {1.0f, 0.0f, 0.0f}, {1.0f, 1.0f, 1.0f}, &local_rand_state)
    ));

    d_list[2] = new XYRect(3.0f, 5.0f, 1.0f, 3.0f, -2.0f,
        new DiffuseLight(Color{4.0f, 4.0f, 4.0f})
    );

    *d_world = new HittableList(d_list, 3);
}

RT_DEVICE inline void cornell_box(Hittable** d_world)
{
    const auto d_list = new Hittable * [8];

    d_list[0] = new YZRect(0.0f, 555.0f, 0.0f, 555.0f, 555.0f, new Lambert(
        Color{0.12f, 0.45f, 0.15f}
    ));
    d_list[1] = new YZRect(0.0f, 555.0f, 0.0f, 555.0f, 0.0f, new Lambert(
        Color{ 0.65f, 0.05f, 0.05f }
    ));
    d_list[2] = new XZRect(213.0f, 343.0f, 227.0f, 332.0f, 554.0f, new DiffuseLight(
        Color{ 15.0f, 15.0f, 15.0f }
    ));
    d_list[3] = new XZRect(0.0f, 555.0f, 0.0f, 555.0f, 0.0f, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));
    d_list[4] = new XZRect(0.0f, 555.0f, 0.0f, 555.0f, 555.0f, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));
    d_list[5] = new XYRect(0.0f, 555.0f, 0.0f, 555.0f, 555.0f, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));

    // Rotated cornell boxes
    // Left
    d_list[6] = new Box(Point3{ 0.0f, 0.0f, 0.0f }, Point3{ 165.0f, 330.0f, 165.0f }, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));
    d_list[6] = new RotateY(d_list[6], 15.0f);
    d_list[6] = new Translate(d_list[6], Vec3{ 265.0f, 0.5f, 295.0f });

    // Right
    d_list[7] = new Box(Point3{ 0.0f, 0.0f, 0.0f }, Point3{ 165.0f, 165.0f, 165.0f }, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));
    d_list[7] = new RotateY(d_list[7], -18.0f);
    d_list[7] = new Translate(d_list[7], Vec3{ 130.0f, 0.5f, 65.0f });

    *d_world = new HittableList(d_list, 8);
}

RT_DEVICE inline void cornell_smoke(Hittable** d_world)
{
    const auto d_list = new Hittable * [8];

    d_list[0] = new YZRect(0.0f, 555.0f, 0.0f, 555.0f, 555.0f, new Lambert(
        Color{ 0.12f, 0.45f, 0.15f }
    ));
    d_list[1] = new YZRect(0.0f, 555.0f, 0.0f, 555.0f, 0.0f, new Lambert(
        Color{ 0.65f, 0.05f, 0.05f }
    ));
    d_list[2] = new XZRect(113.0f, 443.0f, 127.0f, 432.0f, 554.0f, new DiffuseLight(
        Color{ 15.0f, 15.0f, 15.0f }
    ));
    d_list[3] = new XZRect(0.0f, 555.0f, 0.0f, 555.0f, 0.0f, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));
    d_list[4] = new XZRect(0.0f, 555.0f, 0.0f, 555.0f, 555.0f, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));
    d_list[5] = new XYRect(0.0f, 555.0f, 0.0f, 555.0f, 555.0f, new Lambert(
        Color{ 0.73f, 0.73f, 0.73f }
    ));

    // Rotated smoked cornell boxes
    // Left
    d_list[6] = new Box(Point3{ 0.0f, 0.0f, 0.0f }, Point3{ 165.0f, 330.0f, 165.0f }, new Isotropic(
        Color{ 0.0f, 0.0f, 0.0f }
    ));
    d_list[6] = new RotateY(d_list[6], 15.0f);
    d_list[6] = new Translate(d_list[6], Vec3{ 265.0f, 0.5f, 295.0f });
    d_list[6] = new ConstantVolume(d_list[6], 0.01);

    // Right
    d_list[7] = new Box(Point3{ 0.0f, 0.0f, 0.0f }, Point3{ 165.0f, 165.0f, 165.0f }, new Isotropic(
        Color{ 1.0f, 1.0f, 1.0f }
    ));
    d_list[7] = new RotateY(d_list[7], -18.0f);
    d_list[7] = new Translate(d_list[7], Vec3{ 130.0f, 0.5f, 65.0f });
    d_list[7] = new ConstantVolume(d_list[7], 0.01);

    *d_world = new HittableList(d_list, 8);
}

RT_DEVICE inline void infinity_room(Hittable** d_world)
{
    // Setup the random number generation
    curandState_t local_rand_state;
    curand_init(786, 0, 0, &local_rand_state);

    const auto d_list = new Hittable * [2];

    d_list[0] = new Box({ -1.0f, -1.0f, -1.0f }, { 1.0f, 1.0f, 1.0f }, new DiffuseLight(
        new ColoredNoiseTexture(4.0f, { 0.99f, 0.82f, 0.35f}, { 0.80, 0.13, 0.16 }, &local_rand_state)
    ));
    d_list[1] = new Box({ -3.0f, -3.0f, -3.0f }, { 3.0f, 3.0f, 3.0f }, new Metal(
        Color{1.0f, 1.0f, 1.0f}, 0.001f
    ));

    *d_world = new HittableList(d_list, 2);
}

RT_DEVICE inline void infinity_room_textured(Hittable** d_world, ImageWrapper* d_images)
{
    // Setup the random number generation
    curandState_t local_rand_state;
    curand_init(786, 0, 0, &local_rand_state);

    const auto d_list = new Hittable * [2];

    d_list[0] = new Box({ -1.0f, -1.0f, -1.0f }, { 1.0f, 1.0f, 1.0f }, new DiffuseLight(
        new ImageTexture(&d_images[1])
    ));
    d_list[1] = new Box({ -3.0f, -3.0f, -3.0f }, { 3.0f, 3.0f, 3.0f }, new Metal(
        Color{ 1.0f, 1.0f, 1.0f }, 0.001f
    ));

    *d_world = new HittableList(d_list, 2);
}

RT_DEVICE inline void final_scene(Hittable** d_world, ImageWrapper* d_images)
{
    // Setup the random number generation
    curandState_t local_rand_state;
    curand_init(2357, 0, 0, &local_rand_state);

    const auto d_list = new Hittable * [11];

    const auto boxes_per_side = 20;
    const auto d_ground = new Hittable * [boxes_per_side * boxes_per_side];

    size_t index = 0;
    for (size_t i = 0; i < boxes_per_side; ++i)
    {
        for (size_t j = 0; j < boxes_per_side; ++j)
        {
            const auto w = 100.0f;
            const auto x0 = -1000.0f + i * w;
            const auto z0 = -1000.0f + j * w;
            const auto y0 = 0.0f;
            const auto x1 = x0 + w;
            const auto y1 = uniform_rand(&local_rand_state, 0, 101);
            const auto z1 = z0 + w;

            d_ground[index++] = new Box(Point3{ x0, y0, z0 }, Point3{ x1, y1, z1 }, new Lambert(
                Color{ 0.48, 0.83, 0.53 }
            ));
        }
    }

    d_list[0] = new BVH(d_ground, index, &local_rand_state);
    d_list[1] = new XZRect(123, 423, 147, 412, 554, new DiffuseLight(
        Color{ 7, 7, 7 }
    ));

    const auto center_initial = Point3{ 400, 400, 200 };
    const auto center_final = center_initial + Vec3{ 30, 0, 0 };
    d_list[2] = new SphereMoving(center_initial, center_final, 0, 1, 50, new Lambert(
        Color{ 0.7, 0.3, 0.1 }
    ));

    d_list[3] = new Sphere(Point3{ 260, 150, 45 }, 50, new Dielectric(Color{ 1.0, 1.0, 1.0 }, 1.5));
    d_list[4] = new Sphere(Point3{ 0, 150, 145 }, 50, new Metal(Color{ 0.8, 0.8, 0.9 }, 0.0));
    d_list[5] = new Sphere(Point3{ 360, 150, 145 }, 70, new Dielectric(Color{ 1.0, 1.0, 1.0 }, 1.5));

    // Enclosed volume in the sphere with blue tint
    d_list[6] = new Sphere(Point3{ 360, 150, 145 }, 70, new Dielectric(Color{ 1.0, 1.0, 1.0 }, 1.5));
    d_list[6] = new ConstantVolume(d_list[6], 0.2, Color{ 0.2, 0.4, 0.9 });

    d_list[7] = new Sphere(Point3{ 0, 0, 0 }, 5000, new Dielectric(Color{ 1.0, 1.0, 1.0 }, 1.5));
    d_list[7] = new ConstantVolume(d_list[7], .0001, Color{ 1, 1, 1 });

    d_list[8] = new Sphere(Point3{ 400, 200, 400 }, 100, new Lambert(
        new ImageTexture(&d_images[0])
    ));

    // Add the sphere with perlin noise and a custom functor
    const size_t turbulence_depth = 7;
    d_list[9] = new Sphere(Point3{ 220, 280, 300 }, 80, new Lambert(
        new NoiseTexture(0.1, &local_rand_state, turbulence_depth,
            [] RT_DEVICE(const float scale, const Point3 & point, const Perlin & perlin, const size_t depth) -> float
            {
                return 0.5f * (1 + std::sin(scale * point.x() + 10 * perlin.turbulence(point * scale, depth)));
            }
        )
    ));

    const size_t ns = 1000;
    const auto d_spheres_in_cube = new Hittable * [ns];

    index = 0;
    for (size_t j = 0; j < ns; ++j)
    {
        d_spheres_in_cube[index++] = new Sphere(
            Point3
            {
                uniform_rand(&local_rand_state, 0, 165),
                uniform_rand(&local_rand_state, 0, 165) ,
                uniform_rand(&local_rand_state, 0, 165)
            }, 10, new Lambert(Color{0.73, 0.73, 0.73})
        );
    }

    d_list[10] = new BVH(d_spheres_in_cube, index, &local_rand_state);
    d_list[10] = new RotateY(d_list[10], 15.0f);
    d_list[10] = new Translate(d_list[10], Vec3{-100, 270, 395});

    *d_world = new HittableList(d_list, 11);
}

} // namespace ray_tracer
