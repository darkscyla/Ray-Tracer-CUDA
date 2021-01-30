#pragma once

// --- CUDA Includes ---
#include <cuda_runtime.h>
#include <curand_kernel.h>

// --- Standard Includes ---
#include <iostream>
#include <limits>

#define CUDA_CHECK_ERRORS(val) check_cuda( (val), #val, __FILE__, __LINE__)

namespace ray_tracer {

inline void check_cuda(const cudaError_t result, char const* const func, const char* const file, size_t const line)
{
    if(result)
    {
        std::cerr << "CUDA Error at " << file
            << ": " << line << " '" << func << "'\n";
        std::cerr << "--> Error Code: " << static_cast<size_t>(result) << "\n";
        std::cerr << "--> Error Message: " << cudaGetErrorString(result) << "\n";
        cudaDeviceReset();
        exit(99);
    }
}

#define RT_HOST_DEVICE __device__ __host__
#define RT_DEVICE __device__
#define RT_HOST __host__
#define RT_GLOBAL __global__

constexpr auto kInfinity = ::std::numeric_limits<float>::infinity();
constexpr float kPi = 3.1415926535897932385f;
constexpr float k2Pi = 2 * kPi;
constexpr float k1byPi = 1.0f / (kPi);
constexpr float k1by2Pi = 1.0f / (2 * kPi);
constexpr float kPiBy180 = kPi / 180.0f;

RT_DEVICE inline float deg_to_rad(const float degrees)
{
    return degrees * kPiBy180;
}

RT_DEVICE inline float clamp(const float x, const float min, const float max)
{
    return x < min ? min :
        x > max ? max : x;
}

RT_DEVICE inline float random_unit(curandState_t* rand_state)
{
    return curand_uniform(rand_state);
}

RT_DEVICE inline float uniform_rand(curandState_t* rand_state, const float min, const float max)
{
    return min + (max - min) * random_unit(rand_state);
}

} // namespace ray_tracer
