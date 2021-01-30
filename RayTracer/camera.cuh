#pragma once

#include "ray.cuh"

namespace ray_tracer {

class Camera
{
public:
    RT_DEVICE Camera(const Vec3& background, size_t depth, const Point3& look_from, const Point3& look_at,
        const Vec3& up_vector, float v_fov, float aspect_ratio,
        float aperture, float focus_distance, float ti = 0.0f, float tf = 0.0f);
    RT_DEVICE Ray get_ray(curandState_t* rand_state, float u, float v) const;
    RT_DEVICE const Color& background() const;
    RT_DEVICE size_t depth() const;

private:
    Color background_;
    size_t depth_;
    Point3 origin_;
    Vec3 vertical_;
    Vec3 horizontal_;
    Point3 lower_left_corner_;
    Vec3 u_, v_, w_;
    float lens_radius_;
    float ti_, tf_;
};

} // namespace ray_tracer
