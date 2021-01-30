#pragma once

// --- Internal Includes ---
#include "texture.cuh"
#include "image_wrapper.cuh"

namespace ray_tracer {

class ImageTexture : public Texture
{
public:
    RT_DEVICE ImageTexture(ImageWrapper* image);

    RT_DEVICE Color value(const Point3& point, float u, float v) const override;

private:
    ImageWrapper* image_;
};

} // namespace ray_tracer
