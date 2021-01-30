#include "colored_noise_texture.cuh"
#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE ColoredNoiseTexture::ColoredNoiseTexture(const float scale, Texture* low, Texture* high,
    curandState_t* rand_state, const size_t depth, const NoiseFunction function):
    NoiseTexture(scale, rand_state, depth, function),
    low_(low), high_(high)
{
}

RT_DEVICE ColoredNoiseTexture::ColoredNoiseTexture(const float scale, const Color& low, const Color& high, 
    curandState_t* rand_state, const size_t depth, const NoiseFunction function) :
    ColoredNoiseTexture(scale, new SolidTexture(low), new SolidTexture(high), rand_state, 
        depth, function)
{
}

RT_DEVICE ColoredNoiseTexture::~ColoredNoiseTexture()
{
    delete low_;
    delete high_;
}

RT_DEVICE Color ColoredNoiseTexture::value(const Point3& point, float u, float v) const
{
    const auto t = function_(scale_, point, perlin_noise_, depth_);
    return (1 - t) * low_->value(point, u, v) + t * high_->value(point, u, v);
}

} // namespace ray_tracer
