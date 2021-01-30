// --- Internal Includes ---
#include "dielectric.cuh"
#include "hittable.cuh"

namespace ray_tracer {

RT_DEVICE Dielectric::Dielectric(const Color& color, const float refractive_index) :
    albedo_(color), refractive_index_(refractive_index)
{
}

RT_DEVICE bool Dielectric::scatter(curandState_t* rand_state, const Ray& ray_incident,
    const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const
{
    const auto refractive_index = rec.front_face ? 1 / refractive_index_ : refractive_index_;
    const auto unit_incident_ray_direction = unit_vector(ray_incident.direction());

    // Incident ray angle calculations
    const auto cos_incident = -dot(unit_incident_ray_direction, rec.normal);
    const auto sin_incident = std::sqrt(std::abs(1 - cos_incident * cos_incident));

    Vec3 scatter_direction;

    // In case refraction is not possible or desired
    if ((refractive_index * sin_incident > 1.0f) || 
        reflectance(cos_incident, refractive_index) > random_unit(rand_state))
    {
        scatter_direction = reflect(unit_incident_ray_direction, rec.normal);
    }
    else
    {
        scatter_direction = refract(unit_incident_ray_direction, cos_incident, rec.normal, refractive_index);
    }

    ray_scattered = Ray(rec.hit_point, scatter_direction, ray_incident.time());
    attenuation = albedo_;

    return true;
}

RT_DEVICE float Dielectric::reflectance(const float cos_incident, const float refractive_index)
{
    auto r0 = (1 - refractive_index) / (1 + refractive_index);
    r0 *= r0;

    return r0 + (1 - r0) * std::powf(1 - cos_incident, 5);
}

} // namespace ray_tracer
