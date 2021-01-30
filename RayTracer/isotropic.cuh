#pragma once

// -- Internal Includes ---
#include "material.cuh"
#include "texture.cuh"

namespace ray_tracer {

class Isotropic : public Material
{
public:
    RT_DEVICE Isotropic(const Color& color);
    RT_DEVICE Isotropic(Texture* texture);

    RT_DEVICE ~Isotropic();

    RT_DEVICE bool scatter(curandState_t* rand_state, const Ray& ray_incident, 
        const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const override;

private:
    Texture* albedo_;
};

} // namespace ray_tracer
