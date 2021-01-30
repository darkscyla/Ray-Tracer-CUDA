#pragma once

#include "pixel.cuh"
#include <opencv2/highgui/highgui.hpp>

namespace ray_tracer {

class ImageWrapper
{
public:
    RT_HOST ImageWrapper(const std::string file_name) : cols_(0), rows_(0)
    {
        const auto image = cv::imread(file_name, cv::IMREAD_COLOR);

        if (image.empty())
        {
            printf("ERROR: Could not load the texture image file: %s\n", file_name.c_str());
            return;
        }
        if (!image.isContinuous())
        {
            printf("ERROR: The loaded texture: %s is not contiguous\n", file_name.c_str());
            return;
        }

        cols_ = image.cols;
        rows_ = image.rows;

        const auto image_byte_size = static_cast<size_t>(image.cols) * static_cast<size_t>(image.rows) * sizeof(PixelRGB);
        CUDA_CHECK_ERRORS(cudaMalloc(&d_texture_, image_byte_size));
        CUDA_CHECK_ERRORS(cudaMemcpy(d_texture_, image.data, image_byte_size, cudaMemcpyHostToDevice));
    }

    RT_HOST_DEVICE size_t cols() const
    {
        return cols_;
    }

    RT_HOST_DEVICE size_t rows() const
    {
        return rows_;
    }

    RT_HOST_DEVICE Vec3 at(const size_t row, const size_t col) const
    {
        return Vec3{ d_texture_[col + row * cols_]};
    }

    RT_HOST void release_device_data()
    {
        cols_ = 0;
        rows_ = 0;
        CUDA_CHECK_ERRORS(cudaFree(d_texture_));
    }

private:
    size_t cols_;
    size_t rows_;
    PixelRGB* d_texture_;
};

} // namespace ray_tracer
