#include "image_texture.cuh"

namespace ray_tracer {

RT_DEVICE ImageTexture::ImageTexture(ImageWrapper* image) :
    image_(image)
{
}

RT_DEVICE Color ImageTexture::value(const Point3& point, float u, float v) const
{
    if(image_->rows() == 0 || image_->cols() == 0)
    {
        return { 0.0f, 1.0f, 1.0f };
    }

    u = clamp(u, 0.0, 1.0);
    v = 1 - clamp(v, 0.0, 1.0); // Flip coordinates as OpenCV indexes images oppositely

    auto i = static_cast<size_t>(u * image_->cols());
    auto j = static_cast<size_t>(v * image_->rows());

    // The limits of u and v should be [0, 1)
    if (i >= image_->cols())
    {
        i = image_->cols() - 1;
    }
    if (j >= image_->rows())
    {
        j = image_->rows() - 1;
    }

    return image_->at(j, i);
}

} // namespace ray_tracer
