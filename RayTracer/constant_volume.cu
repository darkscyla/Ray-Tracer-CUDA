#include "constant_volume.cuh"
#include "isotropic.cuh"

namespace ray_tracer {

RT_DEVICE ConstantVolume::ConstantVolume(Hittable* hittable, const float density, const Color& color) :
    ConstantVolume(hittable, density, new Isotropic(color))
{
}

RT_DEVICE ConstantVolume::ConstantVolume(Hittable* hittable, const float density, Material* material) :
    hittable_(hittable), neg_density_inv_(-1.0f / density)
{
    material_ = material;
    curand_init(786, 0, 0, &rand_state_);
}

RT_DEVICE ConstantVolume::~ConstantVolume()
{
    delete hittable_;
}

RT_DEVICE bool ConstantVolume::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    // The idea here is to make sure that the underlying object indeed has a volume.
    // For that, we check for 2 intersections with the object. This of course would
    // not hold if the object has holes in it or the object is non-convex
    HitRecord lower;
    HitRecord upper;

    if (!hittable_->hit(ray, -kInfinity, kInfinity, lower))
    {
        return false;
    }

    static const auto eps = 1e-4f;
    // We move the point a bit further to avoid getting the same point again
    if (!hittable_->hit(ray, lower.t + eps, kInfinity, upper))
    {
        return false;
    }

    if (t_min > lower.t) lower.t = t_min;
    if (t_max < upper.t) upper.t = t_max;

    if (lower.t >= upper.t)
    {
        return false;
    }

    if(lower.t < 0.0f) lower.t = 0.0f;

    const auto ray_length = ray.direction().length();
    const auto distance_inside_volume = (upper.t - lower.t) * ray_length;
    const auto random_scatter_distance = neg_density_inv_ * std::log(random_unit(&rand_state_));

    if (random_scatter_distance > distance_inside_volume)
    {
        return false;
    }

    rec.t = lower.t + random_scatter_distance / ray_length;
    rec.hit_point = ray.at(rec.t);

    rec.normal = lower.normal;
    rec.front_face = lower.front_face;
    rec.material = material_ ? material_ : lower.material;

    return true;
}

RT_DEVICE bool ConstantVolume::bounding_box(const float ti, const float tf, AABB& box_out) const
{
    return hittable_->bounding_box(ti, tf, box_out);
}

} // namespace rey_tracer
