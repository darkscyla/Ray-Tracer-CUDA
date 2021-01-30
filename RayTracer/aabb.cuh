#pragma once

// --- Internal Includes ---
#include "ray.cuh"

namespace ray_tracer {

class Hittable;

class AABB
{
public:
    RT_DEVICE AABB() {}
    RT_DEVICE AABB(const Point3& min, const Point3& max);

    RT_DEVICE const Point3& min() const;
    RT_DEVICE const Point3& max() const;

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max) const;

private:
    Point3 minimum_;
    Point3 maximum_;
};

} // namespace ray_tracer
