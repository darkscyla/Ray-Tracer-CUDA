// --- Internal Includes ---
#include "bvh.cuh"
#include "empty.cuh"
#include "aabb_utils.cuh"

// --- Standard Includes ---
#include <thrust/sort.h>

namespace ray_tracer {

RT_DEVICE BVH::BVH(HittableList* hittable_list, curandState_t* rand_state, 
    const float ti, const float tf) :
    BVH(hittable_list->objects(), hittable_list->size(), rand_state, ti, tf)
{
}

RT_DEVICE BVH::BVH(Hittable** hittable_objects, const size_t length,
    curandState_t* rand_state, float ti, float tf) :
    hittable_objects_(hittable_objects)
{
    if (length == 1)
    {
        left_ = hittable_objects_[0];
        right_ = new Empty();
    }

    else if (length == 2)
    {
        left_ = hittable_objects_[0];
        right_ = hittable_objects_[1];
    }
    else
    {
        // Copy over the pointers
        const auto objects = new Hittable * [length];

        for (size_t index = 0; index < length; ++index)
        {
            objects[index] = hittable_objects_[index];
        }

        // We sort along a random direction, not the best but should work fine for now
        const auto axis = static_cast<size_t>(uniform_rand(rand_state, 0, 3)) % 3;
        thrust::sort(objects, objects + length, 
        [axis, ti, tf] RT_DEVICE(Hittable * a, Hittable * b) -> bool
            {
                return box_compare(a, b, axis, ti, tf);
            }
        );

        const auto mid = length / 2;

        left_ = new BVH(objects, mid, rand_state, ti, tf);
        right_ = new BVH(objects + mid, length - mid, rand_state, ti, tf);

        delete[] objects;
    }

    AABB box_left;
    AABB box_right;

    const auto left_has_bb = left_->bounding_box(ti, tf, box_left);
    const auto right_has_bb = right_->bounding_box(ti, tf, box_right);

    if (left_has_bb && right_has_bb)
    {
        box_ = enclosing_box(box_left, box_right);
    }
    else if(left_has_bb)
    {
        box_ = box_left;
    }
    else if(right_has_bb)
    {
        box_ = box_right;
    }
    else
    {
        printf("WARNING: Bounding box is not present for both the objects, this should never happen");
        has_bounding_box_ = false;
    }
}

RT_DEVICE BVH::~BVH()
{
    delete left_;
    delete right_;

    delete[] hittable_objects_;
}

RT_DEVICE bool BVH::hit(const Ray& ray, const float t_min, const float t_max, HitRecord& rec) const
{
    if (has_bounding_box_)
    {
        if (!box_.hit(ray, t_min, t_max))
        {
            return false;
        }
    }

    const auto left_hit = left_->hit(ray, t_min, t_max, rec);
    const auto right_hit = right_->hit(ray, t_min, left_hit ? rec.t : t_max, rec);

    return left_hit || right_hit;
}

RT_DEVICE bool BVH::bounding_box(const float ti, const float tf, AABB& box_out) const
{
    box_out = box_;
    return true;
}

} // namespace ray_tracer
