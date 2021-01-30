#pragma once

// Internal Includes
#include "vec3.cuh"

namespace ray_tracer {

constexpr float kScale = 1.0f / 255.0f;

struct PixelRGB
{
    // We will use OpenCV to read in the image
    // OpenCV indexes oppositely i.e. BGR
    unsigned char b;
    unsigned char g;
    unsigned char r;

    RT_HOST_DEVICE explicit operator Vec3() const
    {
        return { r * kScale, g * kScale, b * kScale};
    }
};

}
