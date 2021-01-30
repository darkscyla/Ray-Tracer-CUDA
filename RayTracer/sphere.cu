#include "sphere.cuh"

namespace ray_tracer {

RT_DEVICE Sphere::Sphere(const Point3& origin, const float radius, Material* material) :
    center_(origin), radius_(radius), radius_inv_(1.0f / radius), radius_2_(radius* radius)
{
    material_ = material;
}

RT_DEVICE bool Sphere::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    const auto oc = ray.origin() - center_;
    const auto a = ray.direction().length_squared();
    const auto b_half = dot(ray.direction(), oc);
    const auto c = oc.length_squared() - radius_2_;
    const auto disc = b_half * b_half - a * c;

    if (disc < 0.0f)
        return false;

    const auto root = std::sqrt(disc);
    const auto a_inv = 1.0f / a;

    auto t = (-b_half - root) * a_inv;

    for (size_t i = 0; i < 2; ++i, t = (-b_half + root) * a_inv)
    {
        if (t < t_max && t > t_min)
        {
            rec.t = t;
            rec.hit_point = ray.at(t);
            const auto outward_normal = (rec.hit_point - center_) * radius_inv_;
            rec.set_face_normal(ray, outward_normal);
            get_uv_coordinates(outward_normal, rec.u, rec.v);
            rec.material = material_;

            return true;
        }
    }

    // Out of bounds
    return false;
}

RT_DEVICE bool Sphere::bounding_box(const float ti, const float tf, AABB& box_out) const
{
    box_out = AABB{
        center_ - Vec3{ radius_, radius_, radius_ },
        center_ + Vec3{ radius_, radius_, radius_ }
    };

    return true;
}

RT_DEVICE void Sphere::get_uv_coordinates(const Point3& point, float& u, float& v)
{
    const auto theta = std::acosf(-point.y());
    const auto phi = std::atan2f(-point.z(), point.x()) + kPi;

    u = phi * k1by2Pi;
    v = theta * k1byPi;
}

} // namespace ray_tracer
