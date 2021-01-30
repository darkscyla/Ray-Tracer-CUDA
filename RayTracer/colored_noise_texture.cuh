#pragma once

#include "noise_texture.cuh"

namespace ray_tracer {

class ColoredNoiseTexture : public NoiseTexture
{
public:
    RT_DEVICE ColoredNoiseTexture(float scale, Texture* low, Texture* high, 
        curandState_t* rand_state, size_t depth = 7, NoiseFunction function = nullptr);

    RT_DEVICE ColoredNoiseTexture(float scale, const Color& low, const Color& high,
        curandState_t* rand_state, size_t depth = 7, NoiseFunction function = nullptr);

    RT_DEVICE ~ColoredNoiseTexture();

    RT_DEVICE Color value(const Point3& point, float u, float v) const override;

private:
    Texture* low_;
    Texture* high_;
};

} // namespace ray_tracer
