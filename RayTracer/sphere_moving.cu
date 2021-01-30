// --- Internal Includes ---
#include "sphere_moving.cuh"
#include "aabb_utils.cuh"

namespace ray_tracer {

RT_DEVICE SphereMoving::SphereMoving(const Point3& origin_initial, const Point3& origin_final,
    const float ti, const float tf, const float radius, Material* material) :
        center_initial_(origin_initial), center_final_(origin_final), ti_(ti), dt_inv_(1.0f / (tf - ti)), radius_(radius),
        radius_inv_(1.0f / radius), radius_2_(radius* radius)
{
    material_ = material;
}

RT_DEVICE Point3 SphereMoving::center(const float time) const
{
    const auto t = (time - ti_) * dt_inv_;
    return (1 - t) * center_initial_ + t * center_final_;
}

RT_DEVICE bool SphereMoving::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    const auto oc = ray.origin() - center(ray.time());
    const auto a = ray.direction().length_squared();
    const auto b_half = dot(ray.direction(), oc);
    const auto c = oc.length_squared() - radius_2_;
    const auto disc = b_half * b_half - a * c;

    // If no intersection, we return a negative number
    if (disc < 0.0)
        return false;

    const auto root = std::sqrt(disc);
    const auto a_inv = 1 / a;

    auto t = (-b_half - root) / a;

    for (size_t i = 0; i < 2; ++i, t = (-b_half + root) * a_inv)
    {
        if (t < t_max && t > t_min)
        {
            rec.t = t;
            rec.hit_point = ray.at(t);
            const auto outward_normal = (rec.hit_point - center(ray.time())) * radius_inv_;
            rec.set_face_normal(ray, outward_normal);
            get_uv_coordinates(outward_normal, rec.u, rec.v);
            rec.material = material_;

            return true;
        }
    }

    // Out of bounds
    return false;
}

RT_DEVICE bool SphereMoving::bounding_box(const float ti, const float tf, AABB& box_out) const
{
    const auto box_i = AABB(
        center(ti) - Vec3{ radius_, radius_, radius_ },
        center(ti) + Vec3{ radius_, radius_, radius_ }
    );

    const auto box_f = AABB(
        center(tf) - Vec3{ radius_, radius_, radius_ },
        center(tf) + Vec3{ radius_, radius_, radius_ }
    );

    box_out = enclosing_box(box_i, box_f);

    return true;
}

RT_DEVICE void SphereMoving::get_uv_coordinates(const Point3& point, float& u, float& v)
{
    const auto theta = std::acosf(-point.y());
    const auto phi = std::atan2f(-point.z(), point.x()) + kPi;

    u = phi * k1by2Pi;
    v = theta * k1byPi;
}

} // namespace ray_tracer
