#pragma once

// --- Internal Includes ---
#include "texture.cuh"
#include "perlin.cuh"

// --- CUDA Includes ---
#include <nvfunctional>

namespace ray_tracer {

class NoiseTexture : public Texture
{
public:
    using NoiseFunction = nvstd::function<float(float, const Point3&, const Perlin&, size_t)>;

    RT_DEVICE NoiseTexture(float scale, curandState_t* rand_state, size_t depth = 7, NoiseFunction function = nullptr);
    RT_DEVICE Color value(const Point3& point, float u, float v) const override;

protected:
    Perlin perlin_noise_;
    float scale_;
    size_t depth_;
    NoiseFunction function_;
};

} // namespace ray_tracer
