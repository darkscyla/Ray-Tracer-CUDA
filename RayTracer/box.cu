// --- Internal Includes ---
#include "box.cuh"
#include "solid_texture.cuh"
#include "xy_rect.cuh"
#include "yz_rect.cuh"
#include "xz_rect.cuh"

namespace ray_tracer {

RT_DEVICE Box::Box(const Point3& box_min, const Point3& box_max, Material* material) :
    box_min_(box_min), box_max_(box_max)
{
    material_ = material;
    const auto d_list = new Hittable * [6];

    d_list[0] = new XYRect(box_min_.x(), box_max_.x(), box_min_.y(), box_max_.y(), box_min_.z(), material_);
    d_list[1] = new XYRect(box_min_.x(), box_max_.x(), box_min_.y(), box_max_.y(), box_max_.z(), material_);

    d_list[2] = new YZRect(box_min_.y(), box_max_.y(), box_min_.z(), box_max_.z(), box_min_.x(), material_);
    d_list[3] = new YZRect(box_min_.y(), box_max_.y(), box_min_.z(), box_max_.z(), box_max_.x(), material_);

    d_list[4] = new XZRect(box_min_.x(), box_max_.x(), box_min_.z(), box_max_.z(), box_min_.y(), material_);
    d_list[5] = new XZRect(box_min_.x(), box_max_.x(), box_min_.z(), box_max_.z(), box_max_.y(), material_);

    sides_ = new HittableList(d_list, 6);
}

RT_DEVICE Box::~Box()
{
    // TODO: Implement CUDA compatible shared pointer
    // Set to nullptr to prevent multiple free of the same resource
    for(size_t index = 0; index < 6; ++index)
    {
        sides_->objects()[index]->material_ = nullptr;
    }

    delete sides_;
}

RT_DEVICE bool Box::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    return sides_->hit(ray, t_min, t_max, rec);
}

RT_DEVICE bool Box::bounding_box(float ti, float tf, AABB& box_out) const
{
    box_out = AABB{ box_min_, box_max_ };
    return true;
}

} // namespace ray_tracer
