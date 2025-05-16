shader_type spatial;
render_mode
	blend_mix,
	depth_draw_opaque,
	cull_back;

#include "StackedSprite.gdshaderinc"

uniform sampler2D albedo_texture : filter_nearest, source_color;
uniform sampler2D normal_texture : filter_nearest;
uniform int frames = 1;
uniform vec4 modulate : source_color = vec4(1);
uniform vec3 emission : source_color = vec3(0);
uniform sampler2D emission_texture : filter_nearest, hint_default_white;
uniform float roughness : hint_range(0, 1) = 1;
uniform sampler2D roughness_texture : filter_nearest, hint_default_white;
uniform float specular : hint_range(0, 1, 0.01) = 0.5;
uniform sampler2D specular_texture : filter_nearest, hint_default_white;
uniform float metallic : hint_range(0, 1, 0.01) = 0;
uniform sampler2D metallic_texture : filter_nearest, hint_default_white;
uniform bool is_perspective;

varying vec3 box_extent;
varying vec3 ray_origin;
varying vec3 ray_direction;
varying float ray_t_step;
varying mat4 model_view_projection_matrix;
varying mat3 normal_matrix;

void vertex()
{
	box_extent = abs(VERTEX);
	ray_origin = VERTEX;
	ray_direction = normalize(is_perspective || PROJECTION_MATRIX[3].w == 0.0
		? ray_origin - (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz
		: inverse(mat3(MODELVIEW_MATRIX)) * vec3(0, 0, -1));
	ray_t_step = max(2.0 * box_extent[COMPONENT_SELECTOR[VERTEX_ID]] / float(MAX_RAYMARCH_STEPS), MIN_RAYMARCH_T);
	model_view_projection_matrix = PROJECTION_MATRIX * MODELVIEW_MATRIX;
	normal_matrix = mat3(MODELVIEW_MATRIX);
}

void fragment()
{
	vec2 uv;
	vec3 color = vec3(0);
	float alpha = 0.0;
	float depth;
	float ray_t = MIN_RAYMARCH_T;
	bool ray_hit = false;
	for (int i = 0; i < MAX_RAYMARCH_STEPS; ++i)
	{
		vec3 ray_hit_position = ray_origin + ray_direction * ray_t;
		vec3 box_position = (ray_hit_position + box_extent) / (box_extent * 2.0);
		if (box_position.x < 0.0 || 1.0 < box_position.x ||
			box_position.y < 0.0 || 1.0 < box_position.y ||
			box_position.z < 0.0 || 1.0 < box_position.z) break;
		box_position.x = 1.0 - box_position.x;
		box_position.z = 1.0 - box_position.z;
		float slice_count = float(frames);
		float slice_offset = floor(box_position.y * slice_count) / slice_count;
		uv = vec2(box_position.x / slice_count + slice_offset, box_position.z);
		vec4 albedo = texture(albedo_texture, uv);
		if (0.0 < albedo.a)
		{
			color += (1.0 - alpha) * albedo.a * albedo.rgb;
			alpha += (1.0 - alpha) * albedo.a;
			if (!ray_hit)
			{
				vec4 ray_clip = model_view_projection_matrix * vec4(ray_hit_position, 1.0);
				depth = ray_clip.z / ray_clip.w;
				ray_hit = true;
			}
		}
		if (1.0 <= alpha) break;
		ray_t += ray_t_step;
	}
	if (!ray_hit) discard;
	ivec2 dither_position = ivec2(FRAGCOORD.xy) % ivec2(4);
	color *= modulate.rgb;
	alpha *= step(DITHER_PATTERN[dither_position.y * 4 + dither_position.x], alpha * modulate.a);
	ALBEDO = color / alpha;
	NORMAL = normalize(normal_matrix * (texture(normal_texture, uv).rgb * 2.0 - 1.0));
	ALPHA = alpha;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
	DEPTH = depth;
	EMISSION = emission * texture(emission_texture, uv).rgb;
	METALLIC = metallic * texture(metallic_texture, uv).r;
	ROUGHNESS = roughness * texture(roughness_texture, uv).r;
	SPECULAR = specular * texture(specular_texture, uv).r;
}
