// --- Internal Includes ---
#include "xz_rect.cuh"
#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE XZRect::XZRect(const float x0, const float x1, const float z0,
    const float z1, const float y, Material* material) :
    x0_(x0), x1_(x1), z0_(z0), z1_(z1), y_(y),
    dx_inv_(1.0f / (x1 - x0)), dz_inv_(1.0f / (z1 - z0))
{
    material_ = material;
}

RT_DEVICE bool XZRect::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    const auto t = (y_ - ray.origin().y()) / ray.direction().y();

    if (t < t_min || t > t_max)
    {
        return false;
    }

    const auto x = ray.origin().x() + t * ray.direction().x();
    const auto z = ray.origin().z() + t * ray.direction().z();

    if (x < x0_ || x > x1_ || z < z0_ || z > z1_)
    {
        return false;
    }

    rec.t = t;
    rec.hit_point = ray.at(t);
    const Vec3 outward_normal{ 0.0f, 1.0f, 0.0f };
    rec.set_face_normal(ray, outward_normal);
    rec.material = material_;

    rec.u = (x - x0_) * dx_inv_;
    rec.v = (z - z0_) * dz_inv_;

    return true;
}

RT_DEVICE bool XZRect::bounding_box(float ti, float tf, AABB& box_out) const
{
    box_out = AABB{ {x0_, y_ - 0.0001f, z0_}, {x1_, y_ + 0.0001f, z1_} };
    return true;
}

} // namespace ray_tracer
