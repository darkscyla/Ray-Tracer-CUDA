#pragma once

// --- Internal Includes ---
#include "hittable.cuh"
#include "vec3.cuh"
#include "rt_utils.cuh"

namespace ray_tracer {

class Sphere final : public Hittable
{
public:
    RT_DEVICE Sphere(const Point3& origin, float radius, Material* material);

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    Point3 center_;
    float radius_;
    float radius_inv_;
    float radius_2_;

    RT_DEVICE static void get_uv_coordinates(const Point3& point, float& u, float& v);
};

} // namespace ray_tracer
