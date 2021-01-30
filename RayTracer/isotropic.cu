#include "isotropic.cuh"
#include "solid_texture.cuh"
#include "hittable.cuh"

namespace ray_tracer {

RT_DEVICE Isotropic::Isotropic(const Color& color) :
    Isotropic(new SolidTexture(color))
{
}

RT_DEVICE Isotropic::Isotropic(Texture* texture) :
    albedo_(texture)
{
}

RT_DEVICE Isotropic::~Isotropic()
{
    delete albedo_;
}

RT_DEVICE bool Isotropic::scatter(curandState_t* rand_state, const Ray& ray_incident, const HitRecord& rec, Color& attenuation,
    Ray& ray_scattered) const
{
    ray_scattered = Ray(rec.hit_point, random_unit_vector(rand_state), ray_incident.time());
    attenuation = albedo_->value(rec.hit_point, rec.u, rec.v);
    return true;
}

} // namespace ray_tracer
