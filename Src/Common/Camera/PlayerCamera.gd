extends Camera2D

const OFFSET_X_DEFAULT: float = 8.0

@export var enable_offset: = false
@export var drag_margin: = 0.125

var offset_x_target: float = OFFSET_X_DEFAULT
var helper_offset_x: float = OFFSET_X_DEFAULT


func _ready() -> void:
	Events.player_direction_changed.connect(on_player_direction_changed)

	drag_left_margin = drag_margin
	drag_right_margin = drag_margin
	drag_top_margin = drag_margin
	drag_bottom_margin = drag_margin

	if enable_offset:
		offset.x = OFFSET_X_DEFAULT


func _process(delta: float) -> void:
	if offset.x != offset_x_target and enable_offset:
		helper_offset_x = lerp(helper_offset_x, offset_x_target, delta * 3)
		if abs(offset_x_target - helper_offset_x) < 0.5:
			helper_offset_x = offset_x_target

		offset.x = floorf(helper_offset_x)


func on_player_direction_changed(new_direction: float) -> void:
	offset_x_target = OFFSET_X_DEFAULT * new_direction
