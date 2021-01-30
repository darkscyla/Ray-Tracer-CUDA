#include "camera.cuh"

namespace ray_tracer {

RT_DEVICE Camera::Camera(const Vec3& background, const size_t depth, 
    const Point3& look_from, const Point3& look_at, const Vec3& up_vector,
    const float v_fov, const float aspect_ratio, const float aperture,
    const float focus_distance, const float ti, const float tf) :
        background_(background),
        depth_(depth)
{
    const auto theta = deg_to_rad(v_fov);
    const auto h = std::tan(theta / 2);
    const auto viewport_height = 2.0f * h;
    const auto viewport_width = aspect_ratio * viewport_height;

    // Aligned camera directions
    w_ = unit_vector(look_from - look_at);
    u_ = unit_vector(cross(up_vector, w_));
    v_ = unit_vector(cross(w_, u_));

    origin_ = look_from;
    horizontal_ = focus_distance * viewport_width * u_;
    vertical_ = focus_distance * viewport_height * v_;
    lower_left_corner_ = origin_ - horizontal_ / 2 - vertical_ / 2 - focus_distance * w_;

    lens_radius_ = aperture / 2;

    ti_ = ti;
    tf_ = tf;
}

RT_DEVICE Ray Camera::get_ray(curandState_t* rand_state, const float u, const float v) const
{
    const auto random_direction = lens_radius_ * random_unit_planer(rand_state);
    const auto offset = u_ * random_direction.x() + v_ * random_direction.y();
    const auto offset_origin = origin_ + offset;

    return { offset_origin, lower_left_corner_ + u * horizontal_ + v * vertical_ - offset_origin,
        uniform_rand(rand_state, ti_, tf_)
    };
}

RT_DEVICE const Color& Camera::background() const
{
    return background_;
}

RT_DEVICE size_t Camera::depth() const
{
    return depth_;
}

} // namespace ray_tracer
