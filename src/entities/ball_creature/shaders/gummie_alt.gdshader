shader_type canvas_item;

uniform vec3 primary_replacement_color;
uniform vec3 secondary_replacement_color;

void fragment() {
	float is_primary_color = step(0.5, COLOR.r);
	float is_secondary_color = 1.0 - is_primary_color;
	vec3 replacement_color = (primary_replacement_color * is_primary_color) +
							 (secondary_replacement_color * is_secondary_color);
	replacement_color /= 255.0;
	COLOR.rgb = replacement_color;
}