#pragma once

// --- Internal Includes ---
#include "hittable.cuh"

namespace ray_tracer {

class YZRect : public Hittable
{
public:
    RT_DEVICE YZRect(float y0, float y1, float z0, float z1, float x, Material* material);

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    float y0_;
    float y1_;
    float z0_;
    float z1_;
    float x_;
    float dy_inv_;
    float dz_inv_;
};

} // namespace ray_tracer
