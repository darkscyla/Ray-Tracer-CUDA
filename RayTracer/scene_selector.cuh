#pragma once

// --- Internal Includes ---
#include "scene.cuh"
#include "camera.cuh"

// --- CUDA Includes ---
#include <device_launch_parameters.h>

namespace ray_tracer {

RT_GLOBAL void select_scene(const size_t id, ImageWrapper* d_textures, Hittable** d_world,  Camera** d_camera, const float aspect_ratio)
{
    if (threadIdx.x == 0 && blockIdx.x == 0)
    {
        Color background;
        Point3 look_from;
        Point3 look_at;
        float v_fov;
        float aperture;

        const auto v_up = Vec3{ 0.0f, 1.0f, 0.0f };
        const auto focus_distance = 10.0f;
        size_t depth = 50;
        const auto ti = 0.0f;
        auto tf = 0.0f;

        switch (id)
        {
            case 0:
                random_scene(d_world);
                background = Color(0.70, 0.80, 1.00);
                look_from = Point3{ 13.0, 2.0, 3.0 };
                look_at = Point3{ 0.0, 0.0, 0.0 };
                v_fov = 20.0;
                aperture = 0.1;
                break;

            case 1:
                two_spheres(d_world);
                background = Color(0.70, 0.80, 1.00);
                look_from = Point3{ 13.0, 2.0, 3.0 };
                look_at = Point3{ 0.0, 0.0, 0.0 };
                v_fov = 20.0;
                aperture = 0.0;
                break;

            case 2:
                two_perlin_spheres(d_world);
                background = Color(0.70, 0.80, 1.00);
                look_from = Point3{ 13.0, 2.0, 3.0 };
                look_at = Point3{ 0.0, 0.0, 0.0 };
                v_fov = 20.0;
                aperture = 0.0;
                break;

            case 3:
                earth(d_world, d_textures);
                background = Color(0.70, 0.80, 1.00);
                look_from = Point3{ 13.0, 2.0, 3.0 };
                look_at = Point3{ 0.0, 0.0, 0.0 };
                v_fov = 20.0;
                aperture = 0.0;
                break;

            case 4:
                simple_light(d_world);
                background = Color(0.0, 0.0, 0.0);
                look_from = Point3{ 26.0, 3.0, 6.0 };
                look_at = Point3{ 0.0, 2.0, 0.0 };
                v_fov = 20.0;
                aperture = 0.0;
                break;

            case 5:
                cornell_box(d_world);
                background = Color(0.0, 0.0, 0.0);
                look_from = Point3{ 278, 278, -800 };
                look_at = Point3{ 278, 278, 0 };
                v_fov = 40.0;
                aperture = 0.0;
                break;

            case 6:
                cornell_smoke(d_world);
                background = Color(0.0, 0.0, 0.0);
                look_from = Point3{ 278, 278, -800 };
                look_at = Point3{ 278, 278, 0 };
                v_fov = 40.0;
                aperture = 0.0;
                break;

            case 7:
                final_scene(d_world, d_textures);
                background = Color(0.0, 0.0, 0.0);
                look_from = Point3{ 478, 278, -600 };
                look_at = Point3{ 278, 278, 0 };
                v_fov = 40.0;
                aperture = 0.0;
                tf = 1.0;
                break;

            case 8:
                infinity_room(d_world);
                background = Color(0.0f, 0.0f, 0.0f);
                look_from = Point3{ 2.95f, 1.75f, 2.95f };
                look_at = Point3{ 0.0f, 0.0f, 0.0f };
                v_fov = 90.0f;
                aperture = 0.0;
                depth = 10;
                break;

            default:
            case 9:
                infinity_room_textured(d_world, d_textures);
                background = Color(0.0f, 0.0f, 0.0f);
                look_from = Point3{ 2.95f, 1.75f, 2.95f };
                look_at = Point3{ 0.0f, 0.0f, 0.0f };
                v_fov = 90.0f;
                aperture = 0.0;
                depth = 10;
                break;
        }

        *d_camera = new Camera(
            background, depth, look_from, look_at, v_up, v_fov, 
            aspect_ratio, aperture, focus_distance, ti, tf
        );

    } // Thread zero
}

} // namespace ray_tracer
