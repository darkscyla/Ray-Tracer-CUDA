// --- Internal Includes ---
#include "xy_rect.cuh"
#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE XYRect::XYRect(const float x0, const float x1, const float y0,
    const float y1, const float z, Material* material) :
    x0_(x0), x1_(x1), y0_(y0), y1_(y1), z_(z),
    dx_inv_(1.0f / (x1 - x0)), dy_inv_(1.0f / (y1 - y0))
{
    material_ = material;
}

RT_DEVICE bool XYRect::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    const auto t = (z_ - ray.origin().z()) / ray.direction().z();

    if (t < t_min || t > t_max)
    {
        return false;
    }

    const auto x = ray.origin().x() + t * ray.direction().x();
    const auto y = ray.origin().y() + t * ray.direction().y();

    if (x < x0_ || x > x1_ || y < y0_ || y > y1_)
    {
        return false;
    }

    rec.t = t;
    rec.hit_point = ray.at(t);
    const Vec3 outward_normal{ 0.0f, 0.0f, 1.0f };
    rec.set_face_normal(ray, outward_normal);
    rec.material = material_;

    rec.u = (x - x0_) * dx_inv_;
    rec.v = (y - y0_) * dy_inv_;

    return true;
}

RT_DEVICE bool XYRect::bounding_box(float ti, float tf, AABB& box_out) const
{
    box_out = AABB{ {x0_, y0_, z_ - 0.0001f}, {x1_, y1_, z_ + 0.0001f} };
    return true;
}

} // namespace ray_tracer
