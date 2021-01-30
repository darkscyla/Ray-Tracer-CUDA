// --- Internal Includes ---
#include "perlin.cuh"

// --- Standard Includes ---
#include <numeric>

namespace ray_tracer {

RT_DEVICE Perlin::Perlin(curandState_t* rand_state)
{
    for(size_t index = 0; index < lattice_points_; ++index)
    {
        random_vectors_[index] = random_unit_vector(rand_state);
    }

    perlin_generate_permutation(perm_x_, rand_state);
    perlin_generate_permutation(perm_y_, rand_state);
    perlin_generate_permutation(perm_z_, rand_state);
}

RT_DEVICE float Perlin::noise(const Point3& point) const
{
    const auto fx = std::floor(point.x());
    const auto fy = std::floor(point.y());
    const auto fz = std::floor(point.z());

    const auto i = static_cast<int>(fx);
    const auto j = static_cast<int>(fy);
    const auto k = static_cast<int>(fz);

    // Perform the Hermitian smoothing
    auto u = point.x() - fx;
    auto v = point.y() - fy;
    auto w = point.z() - fz;
    u = u * u * (3 - 2 * u);
    v = v * v * (3 - 2 * v);
    w = w * w * (3 - 2 * w);

    float accumulate = 0;

    // Pre-compute the products
    float dx_u[2] = {0, u};
    float dy_v[2] = { 0, v };
    float dz_w[2] = {0, w};

    // For powers of 2, & is equivalent to mod operator
    // Get the accumulate using tri-linear interpolation
    for (size_t dx = 0; dx < 2; ++dx)
    {
        for (size_t dy = 0; dy < 2; ++dy)
        {
            for (size_t dz = 0; dz < 2; ++dz)
            {
                const Vec3 weight = { u - dx, v - dy, w - dz };
                accumulate += (dx_u[dx] + (1 - dx) * (1 - u)) *
                    (dy_v[dy] + (1 - dy) * (1 - v)) *
                    (dz_w[dz] + (1 - dz) * (1 - w)) *
                    dot(random_vectors_[
                        perm_x_[(i + dx) & 255] ^
                            perm_y_[(j + dy) & 255] ^
                            perm_z_[(k + dz) & 255]
                    ], weight);
            }
        }
    }

    return accumulate;
}

RT_DEVICE float Perlin::turbulence(const Point3& point, const size_t depth) const
{
    auto accumulate = 0.0;
    auto scalable_point = point;
    auto weight = 1.0;

    for (size_t index = 0; index < depth; ++index)
    {
        accumulate += weight * noise(scalable_point);
        weight *= 0.5;
        scalable_point *= 2;
    }

    return std::fabs(accumulate);
}

RT_DEVICE void Perlin::perlin_generate_permutation(Cache<size_t>& perm, curandState_t* rand_state)
{
    for(size_t index = 0; index < lattice_points_; ++index)
    {
        perm[index] = index;
    }

    permute(perm, lattice_points_, rand_state);
}

RT_DEVICE void Perlin::permute(Cache<size_t>& perm, size_t n, curandState_t* rand_state)
{
    for (auto index = lattice_points_ - 1; index > 0; --index)
    {
        const auto rand_index = static_cast<size_t>(
            uniform_rand(rand_state, 0, lattice_points_)) % lattice_points_;
        
        // Swap the value of the lattice points
        const auto swap = perm[index];
        perm[index] = perm[rand_index];
        perm[rand_index] = swap;
    }
}

} // namespace ray_tracer
