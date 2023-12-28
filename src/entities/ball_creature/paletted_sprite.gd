@tool
class_name PalettedSprite extends Sprite2D

enum colors {
	BLUE_DARK_BLUE,
	GREEN_DARK_GREEN,
	YELLOW_DARK_YELLOW,
	MAGENTA_MAROON,
	PINK_MAROON,
	DARK_YELLOW_BROWN,
	WHEAT_YELLOW_BROWN
}

@export var color: = colors.BLUE_DARK_BLUE : set = _set_color;

# Primary and secondary colors
var _palettes: = {
	colors.BLUE_DARK_BLUE: [Vector3(41, 173, 255), Vector3(29, 43, 83)],
	colors.GREEN_DARK_GREEN: [Vector3(0, 228, 54), Vector3(0, 135, 81)],
	colors.YELLOW_DARK_YELLOW: [Vector3(255, 236, 39), Vector3(255, 163, 0)],
	colors.MAGENTA_MAROON: [Vector3(255, 0, 77), Vector3(126, 37, 83)],
	colors.PINK_MAROON: [Vector3(255, 119, 168), Vector3(126, 37, 83)],
	colors.DARK_YELLOW_BROWN: [Vector3(255, 163, 0), Vector3(171, 82, 54)],
	colors.WHEAT_YELLOW_BROWN: [Vector3(255, 204, 170), Vector3(171, 82, 54)],
}


func _ready() -> void:
	_set_color(color)


func _set_color(new_color: int) -> void:
	if not _palettes.has(new_color) or not material is ShaderMaterial:
		return

	color = new_color

	var palette: Array[Vector3]
	palette.assign(_palettes[new_color])

	(material as ShaderMaterial).set_shader_parameter("primary_replacement_color", palette[0])
	(material as ShaderMaterial).set_shader_parameter("secondary_replacement_color", palette[1])
