#include "aabb.cuh"

namespace ray_tracer {

RT_DEVICE AABB::AABB(const Point3& min, const Point3& max) :
    minimum_(min), maximum_(max)
{
}

RT_DEVICE const Point3& AABB::min() const
{
    return minimum_;
}

RT_DEVICE const Point3& AABB::max() const
{
    return maximum_;
}

RT_DEVICE bool AABB::hit(const Ray& ray, float t_min, float t_max) const
{
    for (size_t dim = 0; dim < 3; ++dim)
    {
        auto t_near = (minimum_[dim] - ray.origin()[dim]) * ray.direction_inverse()[dim];
        auto t_far = (maximum_[dim] - ray.origin()[dim]) * ray.direction_inverse()[dim];

        if (ray.sign(dim))
        {
            const auto swap_val = t_near;
            t_near = t_far;
            t_far = swap_val;
        }

        t_min = std::fmaxf(t_min, t_near);
        t_max = std::fminf(t_max, t_far);

        if (t_max <= t_min)
        {
            return false;
        }
    }

    return true;
}

} // namespace ray_tracer
