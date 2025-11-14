shader_type spatial;
render_mode world_vertex_coords, depth_draw_opaque;

uniform float frequency = 0.1;
uniform float amplitude = 5.0;
uniform float time = 0.0;

varying float wave;

void vertex() {
	wave = sin((VERTEX.x * frequency) + time);
	VERTEX.y = wave * amplitude;
}

void fragment() {
	ALBEDO = vec3(0.3, 0.3, 0.7) + (vec3(0.3, 0.3, 0.3) * wave);
}
