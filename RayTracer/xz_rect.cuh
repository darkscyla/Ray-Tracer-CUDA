#pragma once

// --- Internal Includes ---
#include "hittable.cuh"

namespace ray_tracer {

class XZRect : public Hittable
{
public:
    RT_DEVICE XZRect(float x0, float x1, float z0, float z1, float y, Material* material);

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    float x0_;
    float x1_;
    float z0_;
    float z1_;
    float y_;
    float dx_inv_;
    float dz_inv_;
};

} // namespace ray_tracer
