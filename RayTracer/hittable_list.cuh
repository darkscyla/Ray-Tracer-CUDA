#pragma once

// --- Internal Includes ---
#include "hittable.cuh"
#include "rt_utils.cuh"


namespace ray_tracer {

class HittableList final : public Hittable
{
public:
    RT_DEVICE HittableList(Hittable** hittable_list, size_t list_size);
    RT_DEVICE ~HittableList();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

    RT_DEVICE size_t size() const;
    RT_DEVICE Hittable** objects() const;

private:
    Hittable** hittable_list_;
    size_t list_size_ = 0;
};

} // namespace ray_tracing
