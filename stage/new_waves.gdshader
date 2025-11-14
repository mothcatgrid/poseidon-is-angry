// NOTE: Shader automatically converted from Godot Engine 4.5.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, world_vertex_coords;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv_scale;
uniform vec3 uv_offset;

uniform float amplitude = 4.0;
uniform float frequency = 0.1;
uniform float speed = 0.5;

uniform float time = 0.0;
varying vec3 wave_pos;

void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
	// wave stuff
	float time_speed = time * speed;
	VERTEX.y = (sin((VERTEX.x * frequency) + time_speed) + cos((VERTEX.x * frequency * 0.5) - time_speed)) * amplitude;
	//VERTEX.y += cos(VERTEX.x * frequency * 0.1 + time_speed * 2.0) * amplitude * 3.0;
	//VERTEX.x += cos(VERTEX.x * frequency - time_speed) * amplitude;
	//VERTEX.x += cos((VERTEX.x * frequency * 0.3) - time_speed) * amplitude * 3.0;
	//VERTEX.z += cos((VERTEX.z * frequency * 0.3) - time_speed) * amplitude * 3.0;

	float y_prime = (cos((VERTEX.x * frequency) + time_speed) - sin((VERTEX.x * frequency * 0.5) - time_speed)) * amplitude;
	NORMAL = normalize(vec3(-y_prime, 1.0, 0.0));
	//VERTEX.x += cos((VERTEX.x * frequency) + time) * amplitude * 2.0;
	wave_pos = VERTEX;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	// float wave_factor = pow((wave_pos.y + amplitude) / amplitude, 3);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
