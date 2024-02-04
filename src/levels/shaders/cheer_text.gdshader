shader_type canvas_item;

void fragment() {
	float alpha = step(0.5, COLOR.a);
	COLOR.a = alpha;
}