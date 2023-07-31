class_name PlayerMoveState extends State

const MAX_RUN_SPEED := 150.0
const MAX_FALL_SPEED := 200.0
const ACCELERATION := 400.0
const TURN_ACCELERATION := 800.0
const FRICTION := 500.0

@export var character: CharacterBody2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_speed: float = MAX_RUN_SPEED
var gravity_scale: float = 1.0
var acceleration_scale: float = 1.0
var friction_scale: float = 1.0
var face_direction: float = 1.0
var previous_input_direction: float = 1.0


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		var params := StateParams.new()
		params.initiated_jumping = true
		state_machine.transition_to("Air", params)
		return

	if event.is_action_pressed("action") and character.pickable_objects.size() > 0:
		state_machine.transition_to("Pickup")
		return


func physics_process(delta: float) -> void:
	character.velocity.y += gravity * gravity_scale * delta

	var input_direction: float = Input.get_axis("move_left", "move_right")
	var move_direction: float = sign(character.velocity.x)

	var acceleration = ACCELERATION

	if input_direction != 0.0:
		if input_direction != previous_input_direction:
			Events.player_direction_changed.emit(input_direction)
			previous_input_direction = input_direction
			face_direction = input_direction

		# Turning to the other side while moving should higher acceleration
		if move_direction != input_direction:
			acceleration = TURN_ACCELERATION

	if input_direction:
		character.velocity.x = move_toward(
			character.velocity.x,
			input_direction * max_speed,
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
