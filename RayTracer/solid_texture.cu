#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE SolidTexture::SolidTexture(const Color& color) : color_(color)
{
}

RT_DEVICE SolidTexture::SolidTexture(const float r, const float g, const float b) : color_({ r, g, b })
{
}

RT_DEVICE Color SolidTexture::value(const Point3& point, const float u, const float v) const
{
    return color_;
}

} // namespace ray_tracer
