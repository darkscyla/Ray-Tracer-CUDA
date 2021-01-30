#pragma once

// --- Internal Includes ---
#include "hittable_list.cuh"

namespace ray_tracer {

class BVH final : public Hittable
{
public:
    RT_DEVICE BVH(HittableList* hittable_list, curandState_t* rand_state, float ti = 0, float tf = 0);
    RT_DEVICE BVH(Hittable** hittable_objects,
        size_t length, curandState_t* rand_state, float ti = 0.0f, float tf = 0.0f);

    RT_DEVICE ~BVH();

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    Hittable** hittable_objects_;
    Hittable* left_;
    Hittable* right_;
    AABB box_;
    bool has_bounding_box_ = true;
};

} // namespace ray_tracer
