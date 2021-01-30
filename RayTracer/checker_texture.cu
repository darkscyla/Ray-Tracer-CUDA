// --- Internal Includes ---
#include "checker_texture.cuh"
#include "solid_texture.cuh"

// --- Standard Includes ---
#include <cmath>

namespace ray_tracer {

RT_DEVICE CheckerTexture::CheckerTexture(Texture* even, Texture* odd) :
    even_(even), odd_(odd)
{
}

RT_DEVICE CheckerTexture::CheckerTexture(const Color& even_color, const Color& odd_color) :
    even_(new SolidTexture(even_color)),
    odd_(new SolidTexture(odd_color))
{
}

RT_DEVICE CheckerTexture::~CheckerTexture()
{
    delete even_;
    delete odd_;
}

RT_DEVICE Color CheckerTexture::value(const Point3& point, const float u, const float v) const
{
    //const auto sins_sign = ( std::sin(10 * point.x()) * 
    //                         std::sin(10 * point.y()) * 
    //                         std::sin(10 * point.z()) ) < 0;
    const auto sins_sign = (std::sin(500 * u) * std::sin(500 * v) < 0);

    return sins_sign ? odd_->value(point, u, v) : even_->value(point, u, v);
}

} // namespace ray_tracer
