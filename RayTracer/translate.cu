#include "translate.cuh"

namespace ray_tracer {

RT_DEVICE Translate::Translate(Hittable* hittable, const Vec3& offset) :
    hittable_(hittable), offset_(offset)
{
}

RT_DEVICE Translate::~Translate()
{
    delete hittable_;
}

RT_DEVICE bool Translate::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    const Ray ray_displaced{ ray.origin() - offset_, ray.direction(), ray.time() };

    if (!hittable_->hit(ray_displaced, t_min, t_max, rec))
    {
        return false;
    }

    rec.hit_point += offset_;
    rec.set_face_normal(ray_displaced, rec.normal);

    return true;
}

RT_DEVICE bool Translate::bounding_box(const float ti, const float tf, AABB& box_out) const
{
    if (!hittable_->bounding_box(ti, tf, box_out))
    {
        return false;
    }

    box_out = AABB{ box_out.min() + offset_, box_out.max() + offset_ };
    return true;
}

} // namespace ray_tracer
