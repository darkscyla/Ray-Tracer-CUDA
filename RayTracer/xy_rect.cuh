#pragma once

// --- Internal Includes ---
#include "hittable.cuh"

namespace ray_tracer {

class XYRect : public Hittable
{
public:
    RT_DEVICE XYRect(float x0, float x1, float y0, float y1, float z, Material* material);

    RT_DEVICE bool hit(const Ray& ray, float t_min, float t_max, HitRecord& rec) const override;
    RT_DEVICE bool bounding_box(float ti, float tf, AABB& box_out) const override;

private:
    float x0_;
    float x1_;
    float y0_;
    float y1_;
    float z_;
    float dx_inv_;
    float dy_inv_;
};

} // namespace ray_tracer
