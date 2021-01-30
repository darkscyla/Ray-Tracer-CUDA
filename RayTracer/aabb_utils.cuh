#pragma once

#include "hittable.cuh"
#include "aabb.cuh"

namespace ray_tracer {

RT_DEVICE inline AABB enclosing_box(const AABB& box, const AABB& other_box)
{
    const Point3 lower{
        fmin(box.min().x(), other_box.min().x()),
        fmin(box.min().y(), other_box.min().y()),
        fmin(box.min().z(), other_box.min().z())
    };

    const Point3 upper{
        fmax(box.max().x(), other_box.max().x()),
        fmax(box.max().y(), other_box.max().y()),
        fmax(box.max().z(), other_box.max().z())
    };

    return { lower, upper };
}

RT_DEVICE inline bool box_compare(Hittable* a, Hittable* b, const size_t axis,
    const float ti, const float tf)
{
    AABB box_a;
    AABB box_b;

    if (!a->bounding_box(ti, tf, box_a) || !b->bounding_box(ti, tf, box_b))
    {
        printf("No bounding box found in one of the objects provided in BVH constructor");
    }

    return box_a.min()[axis] < box_b.min()[axis];
}

} // namespace ray_tracer
