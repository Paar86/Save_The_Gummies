class_name PeekCamera extends Camera2D

signal arrived_at_player

@export var player_camera: Camera2D
@export var player: Player
var ball_creature: Node2D
var current_target_object: Node2D
var follow_player_camera: bool = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		follow_player_camera = false
		current_target_object = ball_creature

	if event.is_action_released("ui_accept"):
		arrived_at_player.emit()
		follow_player_camera = true


func _ready() -> void:
	assert(player, "Player node not specified!")
	current_target_object = player_camera


# We do the calculation in physics_process to eliminate most of the jitter when the creature is moving
func _physics_process(delta: float) -> void:
	var target_global_position = current_target_object.global_position
	if current_target_object is Camera2D:
		target_global_position = (current_target_object as Camera2D).get_target_position()

	# Don't do anything if the camera is already at destination
	if follow_player_camera:
		global_position = player_camera.get_target_position()
		return

	global_position = lerp(global_position, target_global_position, delta * 5)
	if (target_global_position - global_position).length() < 1:
		global_position = target_global_position
