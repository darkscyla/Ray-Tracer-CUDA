// --- Internal Includes ---
#include "metal.cuh"
#include "hittable.cuh"

namespace ray_tracer {

RT_DEVICE Metal::Metal(const Color& color, const float roughness) :
    albedo_(color), roughness_(clamp(roughness, 0.0f, 1.0f))
{
}

RT_DEVICE bool Metal::scatter(curandState_t* rand_state, const Ray& ray_incident, 
    const HitRecord& rec,Color& attenuation, Ray& ray_scattered) const
{
    const auto reflect_direction = reflect(unit_vector(ray_incident.direction()), rec.normal);
    ray_scattered = Ray(rec.hit_point, reflect_direction + 
        roughness_ * random_aligned_unit_vector(rand_state,  rec.normal), ray_incident.time());
    attenuation = albedo_;

    return true;
}

} // namespace ray_tracer
