class_name PlayerCarryState extends State

const THROW_STRENGTH: = 800.0
const MAX_SPEED_OVERRIDE: = move_state.MAX_RUN_SPEED_DEFAULT / 2

@export var move_state: PlayerMoveState

var _can_throw: = false
var _is_aiming: = false
var _is_fast_aiming_up: = false

# How long until aim arrow is shown
@onready var _to_aim_timer: Timer = $ToAimTimer


func _ready() -> void:
	Events.player_pickup_drop_requested.connect(_on_player_pickup_drop_requested)


func physics_process(delta: float) -> void:
#	if not is_aiming:
	move_state.physics_process(delta)

	if not move_state.character.is_on_floor():
		release_pickup(Vector2.ZERO)
		state_machine.transition_to("Air")
		return

	var direction_vertical: = Input.get_axis("move_up", "move_down")
	_is_fast_aiming_up = true if direction_vertical < 0 else false


func on_enter(params: StateParams) -> void:
	move_state.character.pickup_transform.set_deferred("remote_path", move_state.character.hold_object.get_path())
	move_state.max_speed = MAX_SPEED_OVERRIDE


func on_exit() -> void:
	move_state.max_speed = move_state.MAX_RUN_SPEED_DEFAULT


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		_can_throw = true
		_to_aim_timer.start()

	if event.is_action_released("action") and _can_throw:
		var impulse = move_state.character.aim_direction * THROW_STRENGTH

		# If player holds "up" key and quickly presses "action" button
		if not _is_aiming and _is_fast_aiming_up:
			impulse = get_fast_vertical_impulse()

		release_pickup(impulse)

	if event.is_action_released("move_down"):
		release_pickup(Vector2.ZERO)


func release_pickup(impulse: Vector2) -> void:
	var thrown_object = move_state.character.hold_object as BallCreature
	if not thrown_object:
		return

	thrown_object.collision_layer = 0
	move_state.character.hold_object = null
	move_state.character.pickup_transform.set_deferred("remote_path", null)
	thrown_object.set_deferred("freeze", false)
	thrown_object.call_deferred("apply_central_impulse", impulse)
	thrown_object.enable_collision()
	Events.player_aiming_called_off.emit()
	_to_aim_timer.stop()
	_can_throw = false
	_is_aiming = false

	if impulse != Vector2.ZERO:
		state_machine.transition_to("Kick")
		await get_tree().create_timer(0.07).timeout
		thrown_object.collision_layer = 8
		return

	thrown_object.collision_layer = 8
	state_machine.transition_to("Idle")


# For throwing creature upwards without aiming with crosshair
func get_fast_vertical_impulse() -> Vector2:
	var rotated_up_vector = Vector2.UP.rotated(deg_to_rad(10.0) * move_state.face_direction)
	var angle_rad = Vector2.RIGHT.angle_to(rotated_up_vector)
	return Vector2.RIGHT.rotated(angle_rad).normalized() * THROW_STRENGTH


func on_to_aim_timer_timeout() -> void:
	Events.player_aiming_requested.emit()
	_is_aiming = true


func _on_player_pickup_drop_requested() -> void:
	release_pickup(Vector2.ZERO)
