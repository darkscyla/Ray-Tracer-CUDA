// --- Internal Includes ---
#include "lambert.cuh"
#include "hittable.cuh"
#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE Lambert::Lambert(const Color& color) : albedo_( new SolidTexture(color))
{
}

RT_DEVICE Lambert::Lambert(Texture* texture): albedo_(texture)
{
}

RT_DEVICE Lambert::~Lambert()
{
    delete albedo_;
}

RT_DEVICE bool Lambert::scatter(curandState_t* rand_state, const Ray& ray_incident,
                      const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const
{
    ray_scattered = Ray(rec.hit_point, random_aligned_unit_vector(rand_state, rec.normal), ray_incident.time());
    attenuation = albedo_->value(rec.hit_point, rec.u, rec.v) ;

    return true;
}

} // namespace ray_tracer
