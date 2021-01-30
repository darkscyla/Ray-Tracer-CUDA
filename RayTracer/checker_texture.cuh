#pragma once

// --- Internal Includes ---
#include "texture.cuh"

namespace ray_tracer {

class CheckerTexture final: public Texture
{
public:
    RT_DEVICE CheckerTexture(Texture* even, Texture* odd);
    RT_DEVICE CheckerTexture(const Color& even_color, const Color& odd_color);

    RT_DEVICE ~CheckerTexture();

    RT_DEVICE Color value(const Point3& point, float u, float v) const override;

private:
    Texture* even_;
    Texture* odd_;
};

} // namespace ray_tracer
