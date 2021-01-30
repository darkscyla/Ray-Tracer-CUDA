#include "diffuse_light.cuh"
#include "solid_texture.cuh"

namespace ray_tracer {

RT_DEVICE DiffuseLight::DiffuseLight(Texture* texture, const float emissivity) :
    emit_(texture),
    emissivity_(emissivity)
{
}

RT_DEVICE DiffuseLight::DiffuseLight(const Color& color, const float emissivity) :
    DiffuseLight(new SolidTexture(color), emissivity)
{
}

RT_DEVICE DiffuseLight::~DiffuseLight()
{
    delete emit_;
}

RT_DEVICE bool DiffuseLight::scatter(curandState_t* rand_state, const Ray& ray_incident,
    const HitRecord& rec, Color& attenuation, Ray& ray_scattered) const
{
    return false;
}

RT_DEVICE Color DiffuseLight::emitted(const Point3& point, const float u, const float v)
{
    return emissivity_ * emit_->value(point, u, v);
}

} // namespace ray_tracer
