#pragma once

// --- Internal Includes ---
#include "hittable.cuh"

namespace ray_tracer {

class RotateY : public Hittable
{
public:
    RT_DEVICE RotateY(Hittable* hittable, float angle_deg);

    RT_DEVICE ~RotateY();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    Hittable* hittable_;
    float sin_theta_;
    float cos_theta_;
    bool has_box_;
    AABB bounding_box_;
};

} // namespace ray_tracer
