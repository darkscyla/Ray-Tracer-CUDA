#include "noise_texture.cuh"

namespace ray_tracer {

RT_DEVICE NoiseTexture::NoiseTexture(float scale, curandState_t* rand_state, 
    const size_t depth, NoiseFunction function) :
        perlin_noise_(rand_state), scale_(scale), depth_(depth)
{
    function_ = function ? std::move(function) : []
    RT_DEVICE (const float scale, const Point3& point, const Perlin& perlin, const size_t depth) -> float
    {
        return 0.5f * (1 + std::sin(scale * point.z() + 10 * perlin.turbulence(point, depth)));
    };
}

RT_DEVICE Color NoiseTexture::value(const Point3& point, float u, float v) const
{
    return Color{1.0f, 1.0f, 1.0f} * function_(scale_, point, perlin_noise_, depth_);
}

} // namespace ray_tracer
