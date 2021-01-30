#pragma once

// --- Internal Includes ---
#include "hittable.cuh"
#include "texture.cuh"

namespace ray_tracer {

class ConstantVolume : public Hittable
{
public:
    RT_DEVICE ConstantVolume(Hittable* hittable, float density, const Color& color);
    RT_DEVICE ConstantVolume(Hittable* hittable, float density, Material* material = nullptr);

    RT_DEVICE ~ConstantVolume();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    Hittable* hittable_;
    float neg_density_inv_;
    mutable curandState_t rand_state_;
};

} // namespace ray_tracer
