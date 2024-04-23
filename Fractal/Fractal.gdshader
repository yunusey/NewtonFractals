shader_type canvas_item;

uniform int num_iterations: hint_range(1, 100, 1) = 20;
uniform float scale: hint_range(0.0, 1000.0, 0.01) = 1.0;

// The uniform arrays in Godot must have a fixed size, so we use 10 (as max) here.
uniform int num_roots = 3;
uniform vec2 roots[10];
uniform vec3 root_colors[10]: source_color;

const float CLOSE_ENOUGH = 0.01;

vec2 cartesian_to_polar(vec2 cartesian) {
	// Converts given P(x, y) to P(r, θ) in the complex plane.
	return vec2(length(cartesian), atan(cartesian.y, cartesian.x));
}

vec2 polar_to_cartesian(vec2 polar) {
	// Converts given P(r, θ) to P(x, y) in the complex plane.
	return vec2(cos(polar.y) * polar.x, sin(polar.y) * polar.x);
}

vec2 polar_multiply(vec2 a, vec2 b) {
	// Multiplies P(r1, θ1) with P(r2, θ2)
	return vec2(a.x * b.x, a.y + b.y);
}

vec2 polar_divide(vec2 a, vec2 b) {
	// Divides P(r1, θ1) with P(r2, θ2)
	return vec2(a.x / b.x, a.y - b.y);
}

vec2 cartesian_multiply(vec2 a, vec2 b) {
	// Multiplies P(x1, y1) with P(x2, y2)
	vec2 polar_a = cartesian_to_polar(a);
	vec2 polar_b = cartesian_to_polar(b);
	vec2 polar_mult = polar_multiply(polar_a, polar_b);
	return polar_to_cartesian(polar_mult);
	// You can also use the following to do the same thing without converting to polar:
	// return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cartesian_divide(vec2 a, vec2 b) {
	// Divides P(x1, y1) with P(x2, y2)
	vec2 polar_a = cartesian_to_polar(a);
	vec2 polar_b = cartesian_to_polar(b);
	vec2 polar_div = polar_divide(polar_a, polar_b);
	return polar_to_cartesian(polar_div);
	// You can also use the following to do the same thing without converting to polar:
	// return vec2((a.x * b.x + a.y * b.y) / (b.x * b.x + b.y * b.y), (a.y * b.x - a.x * b.y) / (b.x * b.x + b.y * b.y));
}

vec2 evaluate(vec2 z) {
	// Just evaluates the f(z) at the given z
	vec2 eval = vec2(1.0, 0.0);
	for (int i = 0; i < num_roots; i++) {
		vec2 polar_root = cartesian_to_polar(z - roots[i]);
		eval = polar_multiply(eval, polar_root);
	}
	return polar_to_cartesian(eval);
}

vec2 evaluate_derivative(vec2 z) {
	// Just evaluates the f'(z) at the given z
	vec2 derivative = vec2(0.0, 0.0);
	for (int i = 0; i < num_roots; i++) {
		vec2 term = vec2(1.0, 0.0);
		for (int j = 0; j < num_roots; j++) {
			if (i != j) {
				term = cartesian_multiply(term, z - roots[j]);
			}
		}
		derivative += term;
	}
	return derivative;
}

vec3 find_closest_root(vec2 z) {
	// Iterates num_iterations times to find the closest root to the given coordinate
	for (int i = 0; i < num_iterations; i++) {
		vec2 z_eval = evaluate(z); // f(z)
		vec2 z_prime = evaluate_derivative(z); // f'(z)
		z = z - cartesian_divide(z_eval, z_prime); // z = z - f(z) / f'(z)
	}
	// Find closest root to current z
	int chosen_root = 0;
	float min_distance = length(z - roots[0]);
	for (int i = 1; i < num_roots; i++) {
		float distance = length(z - roots[i]);
		if (distance < min_distance) {
			min_distance = distance;
			chosen_root = i;
			if (min_distance < CLOSE_ENOUGH) {
				break;
			}
		}
	}
	return root_colors[chosen_root];
}

void fragment() {
	// Convert UV to real space (convert to a [-scale, scale] x [-scale, scale] square)
	vec2 real_cord = (UV - 0.5) * scale;
	vec3 closest_root_color = find_closest_root(real_cord);
	COLOR = vec4(closest_root_color, 1.0);
}
