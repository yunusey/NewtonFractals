shader_type canvas_item;

uniform vec3 color: source_color = vec3(1.0, 0.0, 0.0);

void fragment() {
	vec2 centered = UV - 0.5;
	float length_to_origin = length(centered);
	bool is_transparent = length_to_origin > 0.5 || length_to_origin < 0.3;
	bool should_use_border = length_to_origin < 0.35 || length_to_origin > 0.45 && !is_transparent;
	vec3 color_to_use = should_use_border ? vec3(0.0, 0.0, 0.0) : color;
	COLOR = vec4(color_to_use, is_transparent ? 0.0 : 1.0);
}
