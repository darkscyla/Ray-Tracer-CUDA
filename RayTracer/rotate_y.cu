#include "rotate_y.cuh"

namespace ray_tracer {

RT_DEVICE RotateY::RotateY(Hittable* hittable, const float angle_deg) :
    hittable_(hittable)
{
    const auto radians = deg_to_rad(angle_deg);
    cos_theta_ = std::cos(radians);
    sin_theta_ = std::sin(radians);

    // Check if bounding box exists for the base object. We use arbitrary values
    has_box_ = hittable_->bounding_box(0.0f, 1.0f, bounding_box_);

    if (!has_box_)
    {
        return;
    }

    Point3 min{ kInfinity, bounding_box_.min().y(), kInfinity };
    Point3 max{ -kInfinity, bounding_box_.max().y(), -kInfinity };

    for (size_t dx = 0; dx < 2; ++dx)
    {
        for (size_t dz = 0; dz < 2; ++dz)
        {
            // We generate the permutation of the min and max x-z points
            const auto x = dx * bounding_box_.max().x() + (1 - dx) * bounding_box_.min().x();
            const auto z = dz * bounding_box_.max().z() + (1 - dz) * bounding_box_.min().z();

            // Rotation is about origin
            const auto x_dot = x * cos_theta_ + z * sin_theta_;
            const auto z_dot = -x * sin_theta_ + z * cos_theta_;

            const Vec3 extent{ x_dot, 0.0f, z_dot };

            for (size_t dim = 0; dim < 3; dim += 2)
            {
                min[dim] = std::fmin(min[dim], extent[dim]);
                max[dim] = std::fmax(max[dim], extent[dim]);
            }
        }
    }

    bounding_box_ = AABB{ min, max };
}

RT_DEVICE RotateY::~RotateY()
{
    delete hittable_;
}

RT_DEVICE bool RotateY::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    auto origin = ray.origin();
    auto direction = ray.direction();

    // Rotate the ray by angle
    origin[0] = ray.origin().x() * cos_theta_ - ray.origin().z() * sin_theta_;
    origin[2] = ray.origin().x() * sin_theta_ + ray.origin().z() * cos_theta_;

    direction[0] = ray.direction().x() * cos_theta_ - ray.direction().z() * sin_theta_;
    direction[2] = ray.direction().x() * sin_theta_ + ray.direction().z() * cos_theta_;

    const Ray ray_rotated{ origin, direction, ray.time() };

    if (!hittable_->hit(ray_rotated, t_min, t_max, rec))
    {
        return false;
    }

    auto point = rec.hit_point;
    auto normal = rec.normal;

    // Un-rotate the ray by angle
    point[0] = rec.hit_point.x() * cos_theta_ + rec.hit_point.z() * sin_theta_;
    point[2] = -rec.hit_point.x() * sin_theta_ + rec.hit_point.z() * cos_theta_;

    normal[0] = rec.normal.x() * cos_theta_ + rec.normal.z() * sin_theta_;
    normal[2] = -rec.normal.x() * sin_theta_ + rec.normal.z() * cos_theta_;

    rec.hit_point = point;
    rec.set_face_normal(ray_rotated, normal);

    return true;
}

RT_DEVICE bool RotateY::bounding_box(float ti, float tf, AABB& box_out) const
{
    if (has_box_)
    {
        box_out = bounding_box_;
        return true;
    }

    return false;
}

} // namespace ray_tracer
