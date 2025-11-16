shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, world_vertex_coords;

uniform vec4 albedo : source_color;

uniform float steepness: hint_range(0.0, 1.0) = 0.5;
uniform float wavelength = 0.0;
uniform vec2 direction;
uniform float time = 0.0;
uniform float gravity = 9.8;

// dirx, diry, steepness, wavelength
uniform vec4 wave_a;
uniform vec4 wave_b;
uniform vec4 wave_c;

vec3 GerstnerWave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal, float timemod) {
    float s = wave.z;
    float w = wave.w;
    float k = 2.0 * PI / w;
	float c = sqrt(timemod / k);
	vec2 d = normalize(wave.xy);
	float f = k * (dot(d, p.xz) - c * time);
	float a = s / k;

	tangent += vec3(
		-d.x * d.x * (s * sin(f)),
		d.x * (s * cos(f)),
		-d.x * d.y * (s * sin(f))
	);
	binormal += vec3(
		-d.x * d.y * (s * sin(f)),
		d.y * (s * cos(f)),
		-d.y * d.y * (s * sin(f))
	);
	return vec3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
}

void vertex() {
	vec3 gridPoint = VERTEX.xyz;
	vec3 tangent = vec3(1, 0, 0);
	vec3 binormal = vec3(0, 0, 1);
	vec3 p = gridPoint;
	p += GerstnerWave(wave_a, gridPoint, tangent, binormal, gravity);
	p += GerstnerWave(wave_b, gridPoint, tangent, binormal, gravity);
	p += GerstnerWave(wave_c, gridPoint, tangent, binormal, gravity);
	vec3 normal = normalize(cross(binormal, tangent));
	VERTEX = p;
	NORMAL = normal;
}

void fragment() {
	ALBEDO = albedo.rgb;
}
