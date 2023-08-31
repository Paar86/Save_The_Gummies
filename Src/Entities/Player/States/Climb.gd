extends State

signal passed_ladder_threshold

const CLIMBING_SPEED: float = 24.0
const LADDER_EXIT_FORCE: float = 150.0
# How many pixels from the bottom to disable character's collision shape
const CHARACTER_COLLISION_TOGGLE_TRHESHOLD: = 8.0

@export var character: Player = null
var climbed_ladder: Area2D = null
var ladder_bottom: int = 0
var ladder_top: int = 0
var ladder_threshold: int = 0
var is_above_threshold: = false


func on_enter(params: StateParams) -> void:
	assert(character, "Character node cannot be null!")

	character.toggle_hitbox_collider(false)
	passed_ladder_threshold.connect(on_ladder_threshold_passed)
	var is_climbing_down: = false
	if params:
		is_climbing_down = params.climbing_down

	climbed_ladder = character.ladders_under_player[0] if is_climbing_down else character.touching_ladders[0]
	var ladder_boundaries = climbed_ladder.get_ladder_boundaries_global()
	ladder_top = ladder_boundaries.position.y
	ladder_bottom = ladder_boundaries.end.y
	ladder_threshold = ladder_bottom - CHARACTER_COLLISION_TOGGLE_TRHESHOLD

	character.global_position.x = climbed_ladder.global_position.x
	if params and params.climbing_down:
		character.global_position.y = ladder_top
		character.toggle_world_collision(false)
		state_machine.change_animation("ladder_edge")

	if params and params.climbing_up:
		state_machine.change_animation("ladder")


func on_exit() -> void:
	character.toggle_hitbox_collider(true)
	passed_ladder_threshold.disconnect(on_ladder_threshold_passed)
	is_above_threshold = false


func physics_process(delta: float) -> void:
	var climbing_direction: = Input.get_axis("move_down", "move_up")
	character.velocity = Vector2.UP * climbing_direction * CLIMBING_SPEED
	state_machine.change_animation_speed_scale(0.0)
	if climbing_direction:
		state_machine.change_animation_speed_scale(1.0)

	character.move_and_slide()

	if character.global_position.y < ladder_top + 3:
		state_machine.change_animation("ladder_edge")
	else:
		state_machine.change_animation("ladder")

	var is_above_threshold_old: = is_above_threshold
	is_above_threshold = character.global_position.y < ladder_threshold
	if is_above_threshold != is_above_threshold_old:
		passed_ladder_threshold.emit(is_above_threshold)

	if character.global_position.y < ladder_top:
		character.velocity = Vector2.ZERO
		character.global_position.y = ladder_top
		character.toggle_world_collision(true)
		state_machine.transition_to("Idle")
		return

	if character.is_on_floor():
		state_machine.transition_to("Idle")
		return


func on_ladder_threshold_passed(above_threshold: bool) -> void:
	# Is the character is above threshold, we want to disable the collision
	character.toggle_world_collision(not above_threshold)


func on_player_exited_ladder() -> void:
	var params = StateParams.new()
	params.initial_impulse = Vector2.UP * LADDER_EXIT_FORCE
	state_machine.transition_to("Air", params)
