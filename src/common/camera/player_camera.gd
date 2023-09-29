extends Camera2D

const OFFSET_X_DEFAULT: float = 8.0

@export var drag_margin: = 0.125

var _enable_offset: = false
var _offset_x_target: float = 0.0
var _helper_offset_x: float = 0.0
var _player_direction: float = 1.0


func _ready() -> void:
	Events.player_direction_changed.connect(_on_player_direction_changed)
	Events.player_aiming_requested.connect(_on_player_aiming_reqested)
	Events.player_aiming_called_off.connect(_on_player_aiming_called_off)

	drag_left_margin = drag_margin
	drag_right_margin = drag_margin
	drag_top_margin = drag_margin
	drag_bottom_margin = drag_margin

	if _enable_offset:
		offset.x = OFFSET_X_DEFAULT


func _process(delta: float) -> void:
	if offset.x != _offset_x_target:
		_helper_offset_x = lerp(_helper_offset_x, _offset_x_target, delta * 3)
		if abs(_offset_x_target - _helper_offset_x) < 0.5:
			_helper_offset_x = _offset_x_target

		offset.x = floorf(_helper_offset_x)


func _on_player_direction_changed(new_direction: float) -> void:
	_player_direction = new_direction

	if _enable_offset:
		_offset_x_target = OFFSET_X_DEFAULT * new_direction


func _on_player_aiming_reqested() -> void:
	_offset_x_target = OFFSET_X_DEFAULT * _player_direction
	_enable_offset = true


func _on_player_aiming_called_off() -> void:
	_offset_x_target = 0
	_enable_offset = false
