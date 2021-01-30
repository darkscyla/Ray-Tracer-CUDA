#include "empty.cuh"

namespace ray_tracer {

RT_DEVICE Empty::Empty()
{
}

RT_DEVICE bool Empty::hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const
{
    return false;
}

RT_DEVICE bool Empty::bounding_box(float ti, float tf, AABB& box_out) const
{
    return false;
}

} // namespace ray_tracer
