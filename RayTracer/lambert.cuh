#pragma once

// --- Internal Includes ---
#include "material.cuh"
#include "texture.cuh"

namespace ray_tracer {

class Lambert : public Material
{
public:
    RT_DEVICE Lambert(const Color& color);
    RT_DEVICE Lambert(Texture* texture);

    RT_DEVICE ~Lambert();

    RT_DEVICE bool scatter(curandState_t* rand_state, const Ray& ray_incident, 
        const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const override;

private:
    Texture* albedo_;
};

} // namespace ray_tracer
