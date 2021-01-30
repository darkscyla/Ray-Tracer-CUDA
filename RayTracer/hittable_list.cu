#include "hittable_list.cuh"
#include "aabb_utils.cuh"

namespace ray_tracer {

RT_DEVICE HittableList::HittableList(Hittable** hittable_list, const size_t list_size) :
    hittable_list_(hittable_list), list_size_(list_size)
{
}

RT_DEVICE HittableList::~HittableList()
{
    for(size_t i = 0; i < list_size_; ++i)
    {
        delete hittable_list_[i];
    }

    delete[] hittable_list_;
}

RT_DEVICE bool HittableList::hit(const Ray& ray, const float t_min, float t_max, HitRecord& rec) const
{
    auto hit = false;

    for(size_t i = 0; i < list_size_; ++i)
    {
        if(hittable_list_[i]->hit(ray, t_min, t_max, rec))
        {
            hit = true;
            t_max = rec.t;
        }
    }

    return hit;
}

RT_DEVICE bool HittableList::bounding_box(const float ti, const float tf, AABB& box_out) const
{
    if (!list_size_)
    {
        return false;
    }

    const auto object = hittable_list_[0];
    AABB current_box;

    // First object needs to be dealt separately
    if (!object->bounding_box(ti, tf, current_box))
    {
        return false;
    }
    box_out = current_box;

    for (size_t i = 1; i < list_size_; ++i)
    {
        // Compute box updates the current_box
        if (!(hittable_list_[i])->bounding_box(ti, tf, current_box))
        {
            return false;
        }

        // We merge the boxes
        box_out = enclosing_box(box_out, current_box);
    }

    return true;
}

RT_DEVICE size_t HittableList::size() const
{
    return list_size_;
}

RT_DEVICE Hittable** HittableList::objects() const
{
    return hittable_list_;
}

} // namespace ray_tracer
