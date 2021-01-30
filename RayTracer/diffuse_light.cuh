#pragma once

// --- Internal Includes ---
#include "material.cuh"
#include "texture.cuh"

namespace ray_tracer {

class DiffuseLight : public Material
{
public:
    RT_DEVICE DiffuseLight(Texture* texture, float emissivity = 1.0f);
    RT_DEVICE DiffuseLight(const Color& color, float emissivity = 1.0f);

    RT_DEVICE ~DiffuseLight();

    RT_DEVICE bool scatter(curandState_t* rand_state, const Ray& ray_incident, const HitRecord& rec,
        Color& attenuation, Ray& ray_scattered) const override;
    RT_DEVICE Color emitted(const Point3& point, float u, float v) override;

private:
    Texture* emit_;
    float emissivity_;
};

} // namespace ray_tracer
