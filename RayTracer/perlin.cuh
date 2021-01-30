#pragma once

// --- Internal Includes ---
#include "vec3.cuh"

// --- Internal Includes ---
#include <array>

namespace ray_tracer {

class Perlin
{
public:
    RT_DEVICE Perlin(curandState_t* rand_state);
    RT_DEVICE float noise(const Point3& point) const;
    RT_DEVICE float turbulence(const Point3& point, size_t depth = 7) const;

private:
    static const size_t lattice_points_ = 256;

    template<typename T>
    using Cache = T[lattice_points_];

    Cache<Vec3> random_vectors_;
    Cache<size_t> perm_x_;
    Cache<size_t> perm_y_;
    Cache<size_t> perm_z_;

    RT_DEVICE static void perlin_generate_permutation(Cache<size_t>& perm, curandState_t* rand_state);
    RT_DEVICE static void permute(Cache<size_t>& perm, size_t n, curandState_t* rand_state);
};

} // namespace ray_tracer
