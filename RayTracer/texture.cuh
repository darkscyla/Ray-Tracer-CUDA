#pragma once

// --- Internal Includes ---
#include "vec3.cuh"

namespace ray_tracer {

class Texture
{
public:
    RT_DEVICE virtual Color value(const Point3& point, float u, float v) const = 0;

    RT_DEVICE virtual ~Texture() {}
};

} // namespace ray_tracer
