#pragma once

#include "rt_utils.cuh"
#include <curand_kernel.h>

#include <cmath>
#include <iostream>

namespace ray_tracer {

class Vec3
{
public:
    RT_HOST_DEVICE Vec3() : e_{0.0f, 0.0f, 0.0f} {}
    RT_HOST_DEVICE Vec3(const float x, const float y, const float z) : e_{x, y, z} {}

    RT_HOST_DEVICE float x() const { return e_[0]; }
    RT_HOST_DEVICE float y() const { return e_[1]; }
    RT_HOST_DEVICE float z() const { return e_[2]; }

    RT_HOST_DEVICE const Vec3& operator+() const { return *this; }
    RT_HOST_DEVICE Vec3 operator-() const { return { -e_[0], -e_[1], -e_[2] }; }
    RT_HOST_DEVICE float operator[](const size_t index) const { return e_[index]; }
    RT_HOST_DEVICE float& operator[](const size_t index) { return e_[index]; }

    RT_HOST_DEVICE inline Vec3& operator+=(const Vec3& other);
    RT_HOST_DEVICE inline Vec3& operator-=(const Vec3& other);
    RT_HOST_DEVICE inline Vec3& operator*=(const Vec3& other);
    RT_HOST_DEVICE inline Vec3& operator/=(const Vec3& other);
    RT_HOST_DEVICE inline Vec3& operator*=(float t);
    RT_HOST_DEVICE inline Vec3& operator/=(float t);

    RT_HOST_DEVICE float length_squared() const { return e_[0] * e_[0] + e_[1] * e_[1] + e_[2] * e_[2]; }
    RT_HOST_DEVICE float length() const { return std::sqrt(this->length_squared());  }
    RT_HOST_DEVICE void normalize();

private:
    float e_[3];
};

using Point3 = Vec3;
using Color = Vec3;

RT_HOST_DEVICE inline Vec3& Vec3::operator+=(const Vec3& other)
{
    e_[0] += other[0];
    e_[1] += other[1];
    e_[2] += other[2];

    return *this;
}

RT_HOST_DEVICE inline Vec3& Vec3::operator-=(const Vec3& other)
{
    e_[0] -= other[0];
    e_[1] -= other[1];
    e_[2] -= other[2];

    return *this;
}

RT_HOST_DEVICE inline Vec3& Vec3::operator*=(const Vec3& other)
{
    e_[0] *= other[0];
    e_[1] *= other[1];
    e_[2] *= other[2];

    return *this;
}

RT_HOST_DEVICE inline Vec3& Vec3::operator/=(const Vec3& other)
{
    e_[0] /= other[0];
    e_[1] /= other[1];
    e_[2] /= other[2];

    return *this;
}

RT_HOST_DEVICE inline Vec3& Vec3::operator*=(const float t)
{
    e_[0] *= t;
    e_[1] *= t;
    e_[2] *= t;

    return *this;
}

RT_HOST_DEVICE inline Vec3& Vec3::operator/=(const float t)
{
    return this->operator*=( 1.0f / t );
}

RT_HOST_DEVICE inline void Vec3::normalize()
{
    *this /= this->length();
}

RT_HOST inline std::istream& operator>>(std::istream& in, Vec3& vec)
{
    return in >> vec[0] >> vec[1] >> vec[2];
}

RT_HOST inline std::ostream& operator<<(std::ostream& out, const Vec3& vec)
{
    return out << "[ " << vec[0] << ", " << vec[1] << ", " << vec[2] << " ]";
}

RT_HOST_DEVICE inline Vec3 operator+(const Vec3& v1, const Vec3& v2)
{
    return { v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2] };
}

RT_HOST_DEVICE inline Vec3 operator-(const Vec3& v1, const Vec3& v2)
{
    return { v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2] };
}

RT_HOST_DEVICE inline Vec3 operator*(const Vec3& v1, const Vec3& v2)
{
    return { v1[0] * v2[0], v1[1] * v2[1], v1[2] * v2[2] };
}

RT_HOST_DEVICE inline Vec3 operator/(const Vec3& v1, const Vec3& v2)
{
    return { v1[0] / v2[0], v1[1] / v2[1], v1[2] / v2[2] };
}

RT_HOST_DEVICE inline Vec3 operator*(const float t, const Vec3& v)
{
    return {t * v[0], t * v[1] , t * v[2] };
}

RT_HOST_DEVICE inline Vec3 operator*(const Vec3& v, const float t)
{
    return t * v;
}

RT_HOST_DEVICE inline Vec3 operator/(const Vec3& v, const float t)
{
    return v * (1.0f / t);
}

RT_HOST_DEVICE inline float dot(const Vec3& v1, const Vec3& v2)
{
    return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

RT_HOST_DEVICE inline Vec3 cross(const Vec3& v1, const Vec3& v2)
{
    return { (v1[1] * v2[2] - v1[2] * v2[1]),
        (-(v1[0] * v2[2] - v1[2] * v2[0])),
        (v1[0] * v2[1] - v1[1] * v2[0]) };
}

RT_HOST_DEVICE inline Vec3 unit_vector(const Vec3& vec)
{
    return vec / vec.length();
}

// Preserves the color values rather than clamping it
RT_HOST_DEVICE inline void color_correct(Color& color)
{
    auto max = color[0];

    // Find max
    if(color[1] > max) max = color[1];
    if (color[2] > max) max = color[2];

    // Scale down if any component is greater than 1.0f
    if(max > 1.0f)
    {
        color /= max;
    }
}

RT_DEVICE inline Vec3 random_unit_vector(curandState_t* rand_state)
{
    const auto theta = std::acosf(uniform_rand(rand_state, -1.0f, 1.0f));
    const auto phi = uniform_rand(rand_state, 0.0f, k2Pi);
    const auto sin_theta = std::sinf(theta);

    return {
        sin_theta * std::cosf(phi),
        sin_theta * std::sinf(phi),
        std::cosf(theta)
    };
}

RT_DEVICE inline Vec3 random_aligned_unit_vector(curandState_t* rand_state, const Vec3& normal)
{
    const auto random_direction = random_unit_vector(rand_state);
    return dot(random_direction, normal) < 0 ? -random_direction : random_direction;
}

RT_DEVICE inline Vec3 random_unit_planer(curandState_t* rand_state)
{
    const auto theta = uniform_rand(rand_state, 0.0f, k2Pi);

    return {
        std::cosf(theta),
        std::sinf(theta),
        0.0f
    };
}

RT_HOST_DEVICE inline Vec3 reflect(const Vec3& ray_direction, const Vec3& unit_normal)
{
    return ray_direction - 2 * dot(ray_direction, unit_normal) * unit_normal;
}

RT_HOST_DEVICE inline Vec3 refract(const Vec3& ray_direction, const float cos_incident,
    const Vec3& unit_normal, const float relative_refractive_index)
{
    const auto refract_perpendicular = relative_refractive_index * (
        ray_direction + cos_incident * unit_normal);
    const auto refract_parallel = -std::sqrt(
        std::abs(1 - refract_perpendicular.length_squared())) * unit_normal;

    return refract_perpendicular + refract_parallel;
}

RT_HOST_DEVICE inline Vec3 refract(const Vec3& ray_direction, const Vec3& unit_normal,
    const float relative_refractive_index)
{
    return refract(ray_direction, -dot(ray_direction, unit_normal), unit_normal, relative_refractive_index);
}

} // namespace ray_tracer
