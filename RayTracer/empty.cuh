#pragma once

// --- Internal Includes ---
#include "hittable.cuh"

namespace ray_tracer {

class Empty final : public Hittable
{
public:
    RT_DEVICE Empty();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;
};

} // namespace ray_tracer
