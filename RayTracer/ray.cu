// --- Internal Includes ---
#include "ray.cuh"

namespace ray_tracer {

RT_DEVICE Ray::Ray(const Point3& origin, const Vec3& direction, const float time) :
    orig_{ origin }, dir_{ direction },
    inv_dir_{ 1 / direction.x(), 1 / direction.y(), 1 / direction.z() },
    sign_{ inv_dir_[0] < 0, inv_dir_[1] < 0, inv_dir_[2] < 0 },
    time_{ time }
{
}

RT_DEVICE const Point3& Ray::origin() const
{
    return orig_;
}

RT_DEVICE const Vec3& Ray::direction() const
{
    return dir_;
}

RT_DEVICE  const Vec3& Ray::direction_inverse() const
{
    return inv_dir_;
}

RT_DEVICE bool Ray::sign(const size_t direction) const
{
    return sign_[direction];
}

RT_DEVICE float Ray::time() const
{
    return time_;
}

RT_DEVICE Point3 Ray::at(const float t) const
{
    return orig_ + t * dir_;
}

} // namespace ray_tracer
