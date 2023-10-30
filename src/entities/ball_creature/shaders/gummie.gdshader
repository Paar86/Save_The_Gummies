shader_type canvas_item;

uniform int palette :hint_range(0, 6) = 0;

void fragment() {
	vec3 primary;
	vec3 secondary;
	vec4 color = texture(TEXTURE, UV);
	
	switch (palette) {
		case 0:
			primary = vec3(41, 173, 255);
			secondary = vec3(29, 43, 83);
			break;
		case 1:
			primary = vec3(0, 228, 54);
			secondary = vec3(0, 135, 81);
			break;
		case 2:
			primary = vec3(255, 236, 39);
			secondary = vec3(255, 163, 0);
			break;
		case 3:
			primary = vec3(255, 0, 77);
			secondary = vec3(126, 37, 83);
			break;
		case 4:
			primary = vec3(255, 119, 168);
			secondary = vec3(126, 37, 83);
			break;
		case 5:
			primary = vec3(255, 163, 0);
			secondary = vec3(171, 82, 54);
			break;
		case 6:
			primary = vec3(255, 204, 170);
			secondary = vec3(171, 82, 54);
			break;
	}
	if (color.r < 0.5) {
		COLOR.rgb = secondary/255.0;
	} else {
		COLOR.rgb = primary/255.0;
	}
}

