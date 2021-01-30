#pragma once

#include "vec3.cuh"

namespace ray_tracer {

class Ray
{
public:
    RT_DEVICE Ray() {}
    RT_DEVICE Ray(const Point3 & origin, const Vec3 & direction, float time = 0.0f);

    RT_DEVICE const Point3& origin() const;
    RT_DEVICE const Vec3& direction() const;
    RT_DEVICE const Vec3& direction_inverse() const;

    /*
     * Check if the ray direction is negative
     */
    RT_DEVICE bool sign(size_t direction) const;
    RT_DEVICE float time() const;

    RT_DEVICE Point3 at(float t) const;

private:
    Point3 orig_;
    Vec3 dir_;
    Vec3 inv_dir_;
    bool sign_[3];
    float time_;
};

} // namespace ray_tracer
