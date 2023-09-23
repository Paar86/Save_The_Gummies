class_name PlayerMoveState extends State

const MAX_RUN_SPEED_DEFAULT := 80.0
const MAX_FALL_SPEED := 180.0
const ACCELERATION := 200.0
const TURN_ACCELERATION := 400.0
const FRICTION := 250.0

@export var character: GameCharacter

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_speed: float = MAX_RUN_SPEED_DEFAULT
var max_speed_modifier: float = 1.0
var face_direction: float = 1.0

var gravity_scale: float = 1.0
var acceleration_scale: float = 1.0
var friction_scale: float = 1.0

var jump_enabled: = true
var movement_enabled: = true


func _ready() -> void:
	Events.player_direction_changed.connect(on_player_direction_changed)
	Events.player_aiming_requested.connect(on_aiming_requested)
	Events.player_aiming_called_off.connect(on_aiming_called_off)

	character.effect_added.connect(on_effect_added)
	character.effect_removed.connect(on_effect_removed)


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") and character.touching_ladders.size() > 0:
		var params := StateParams.new()
		params.climbing_up = true
		state_machine.transition_to("Climb", params)
		return

	if event.is_action_pressed("move_down") and character.ladders_under_player.size() > 0:
		var params := StateParams.new()
		params.climbing_down = true
		state_machine.transition_to("Climb", params)
		return

	if event.is_action_pressed("jump") and movement_enabled and jump_enabled:
		var params := StateParams.new()
		params.initiated_jumping = true
		state_machine.transition_to("Air", params)
		return

	if event.is_action_pressed("action") and character.pickable_objects.size() > 0:
		state_machine.transition_to("Pickup")
		return


func physics_process(delta: float) -> void:
	character.velocity.y += gravity * gravity_scale * delta
	character.velocity.y = min(character.velocity.y, MAX_FALL_SPEED)

	var input_direction: float = Input.get_axis("move_left", "move_right")
	var move_direction: float = sign(character.velocity.x)

	if not movement_enabled:
		input_direction = 0.0

	var acceleration = ACCELERATION

	if input_direction != 0.0:
		if input_direction != face_direction:
			Events.player_direction_changed.emit(input_direction)

		# Turning to the other side while moving should higher acceleration
		if move_direction != input_direction:
			acceleration = TURN_ACCELERATION

	if input_direction:
		character.velocity.x = move_toward(
			character.velocity.x,
			input_direction * max_speed * max_speed_modifier,
			acceleration * acceleration_scale * delta
		)
	else:
		character.velocity.x = move_toward(
			character.velocity.x,
			0,
			FRICTION * friction_scale * delta
		)

	character.move_and_slide()

	if character.is_on_floor():
		character.velocity.y = 0.0


func on_player_direction_changed(new_direction: float) -> void:
	face_direction = new_direction


func on_aiming_requested() -> void:
	movement_enabled = false


func on_aiming_called_off() -> void:
	movement_enabled = true


func on_effect_added(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			jump_enabled = false
			max_speed_modifier = 0.5


func on_effect_removed(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			jump_enabled = true
			max_speed_modifier = 1.0
