#pragma once

// --- Internal Includes ---
#include "hittable.cuh"

namespace ray_tracer {

class Translate : public Hittable
{
public:
    RT_DEVICE Translate(Hittable* hittable, const Vec3& offset);

    RT_DEVICE ~Translate();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    Hittable* hittable_;
    Vec3 offset_;
};

} // namespace ray_tracer
