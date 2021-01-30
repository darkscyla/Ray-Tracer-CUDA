#pragma once

// --- Internal Includes ---
#include "ray.cuh"
#include "rt_utils.cuh"
#include "material.cuh"
#include "aabb.cuh"

namespace ray_tracer {

struct HitRecord;

class Hittable
{
public:
    RT_DEVICE virtual bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const = 0;
    RT_DEVICE virtual bool bounding_box(float ti, float tf, AABB& box_out) const = 0;

    RT_DEVICE virtual ~Hittable()
    {
        delete material_;   
    };

public:
    Material* material_ = nullptr;
};

struct HitRecord
{
    Point3 hit_point;
    Vec3 normal;
    Material* material;
    float t = 0.0;
    float u = 0.0;
    float v = 0.0;
    bool front_face = false;

    RT_DEVICE void set_face_normal(const Ray& ray, const Vec3& outward_normal)
    {
        front_face = dot(ray.direction(), outward_normal) < 0;
        normal = front_face ? outward_normal : -outward_normal;
    }
};

} // namespace ray_tracer
