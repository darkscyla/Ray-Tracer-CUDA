#pragma once

// --- Internal Includes ---
#include "material.cuh"

namespace ray_tracer {

class Dielectric final : public Material
{
public:
    RT_DEVICE Dielectric(const Color& color, float refractive_index);
    RT_DEVICE bool scatter(curandState_t* rand_state, const Ray& ray_incident, 
        const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const override;

private:
    Color albedo_;
    float refractive_index_;

    /**
     * We use the Schlick's approximation for the fresnel factor
     */
    RT_DEVICE static float reflectance(float cos_incident, float refractive_index);
};

} // namespace ray_tracer
