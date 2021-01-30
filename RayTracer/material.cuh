#pragma once

// --- Internal Includes ---
#include "ray.cuh"

namespace ray_tracer {

struct HitRecord;

class Material
{
public:
    RT_DEVICE virtual bool scatter(curandState_t* rand_state, const Ray& ray_incident, const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const = 0;

    RT_DEVICE virtual Color emitted(const Point3& point, const float u, const float v)
    {
        return { 0.0f, 0.0f, 0.0f };
    }

    RT_DEVICE virtual ~Material(){}
};

} // namespace ray_tracer
