shader_type canvas_item;

uniform float cutoff_value : hint_range(0.0, 1.0);
uniform sampler2D mask : hint_normal;

void fragment() {
	float mask_value = texture(mask, UV).r;
	float alpha = step(cutoff_value, mask_value);
	COLOR = vec4(COLOR.rgb, alpha);
}