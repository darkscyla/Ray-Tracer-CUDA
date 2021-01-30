#pragma once

// --- Internal Includes ---
#include "material.cuh"

namespace ray_tracer {

class Metal : public Material
{
public:
    RT_DEVICE Metal(const Color& color, float roughness);

    RT_DEVICE bool scatter(curandState_t* rand_state, const Ray& ray_incident, const HitRecord& rec, 
        Color& attenuation, Ray& ray_scattered) const override;

private:
    Color albedo_;
    float roughness_;
};

} // namespace ray_tracer
