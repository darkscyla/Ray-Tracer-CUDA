#pragma once

// --- Internal Includes ---
#include "hittable_list.cuh"

namespace ray_tracer {

class Box : public Hittable
{
public:
    RT_DEVICE Box(const Point3& box_min, const Point3& box_max, Material* material);
    RT_DEVICE ~Box();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    Point3 box_min_;
    Point3 box_max_;
    HittableList* sides_;
};

} // namespace ray_tracer
