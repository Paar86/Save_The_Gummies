class_name PeekCamera extends Camera2D

signal arrived_at_player_camera()
signal arrived_at_target(Node2D)

@export var player_camera: Camera2D

var ball_creature: Node2D
var _is_at_target: bool = false

var _current_target_object: Node2D:
	set(value):
		_is_at_target = false
		_current_target_object = value
	get:
		return _current_target_object


func _ready() -> void:
	assert(player_camera, "Player camera node not specified!")
	global_position = player_camera.get_target_position()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		set_ball_creature_as_target()

	if event.is_action_released("ui_accept"):
		_current_target_object = null
		arrived_at_player_camera.emit()


# We do the calculation in physics_process to eliminate most of the jitter when the creature is moving
func _physics_process(delta: float) -> void:
	# Just follow player camera when target is not set
	if not _current_target_object:
		global_position = player_camera.get_target_position()
		return

	var target_global_position: Vector2 = _current_target_object.global_position
	if _current_target_object is Camera2D:
		target_global_position = (_current_target_object as Camera2D).get_target_position()

	global_position = lerp(global_position, target_global_position, delta * 5)
	if (target_global_position - global_position).length() < 1:
		if not _is_at_target:
			_is_at_target = true
			arrived_at_target.emit(_current_target_object)

		global_position = target_global_position


func set_ball_creature_as_target() -> void:
	if not ball_creature:
		return

	_current_target_object = ball_creature


func set_player_camera_as_target() -> void:
	if not player_camera:
		return

	_current_target_object = player_camera
