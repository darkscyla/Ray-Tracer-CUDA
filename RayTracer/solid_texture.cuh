#pragma once

// --- Internal Includes ---
#include "texture.cuh"

namespace ray_tracer {

class SolidTexture : public Texture
{
public:
    RT_DEVICE SolidTexture(const Color& color);
    RT_DEVICE SolidTexture(float r, float g, float b);

    RT_DEVICE Color value(const Point3& point, float u, float v) const override;
private:
    Color color_;
};

} // namespace ray_tracer
