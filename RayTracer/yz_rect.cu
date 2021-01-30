// --- Internal Includes ---
#include "yz_rect.cuh"
#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE YZRect::YZRect(const float y0, const float y1, const float z0,
    const float z1, const float x, Material* material) :
    y0_(y0), y1_(y1), z0_(z0), z1_(z1), x_(x),
    dy_inv_(1.0f / (y1 - y0)), dz_inv_(1.0f / (z1 - z0))
{
    material_ = material;
}

RT_DEVICE bool YZRect::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    const auto t = (x_ - ray.origin().x()) / ray.direction().x();

    if (t < t_min || t > t_max)
    {
        return false;
    }

    const auto y = ray.origin().y() + t * ray.direction().y();
    const auto z = ray.origin().z() + t * ray.direction().z();

    if (y < y0_ || y > y1_ || z < z0_ || z > z1_)
    {
        return false;
    }

    rec.t = t;
    rec.hit_point = ray.at(t);
    const Vec3 outward_normal{ 1.0f, 0.0f, 0.0f };
    rec.set_face_normal(ray, outward_normal);
    rec.material = material_;

    rec.u = (y - y0_) * dy_inv_;
    rec.v = (z - z0_) * dz_inv_;

    return true;
}

RT_DEVICE bool YZRect::bounding_box(float ti, float tf, AABB& box_out) const
{
    box_out = AABB{ {x_ - 0.0001f, y0_, z0_}, {x_ + 0.0001f, y1_, z1_} };
    return true;
}

} // namespace ray_tracer
