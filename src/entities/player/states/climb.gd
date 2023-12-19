extends State

signal passed_ladder_threshold

const CLIMBING_SPEED: float = 24.0
const LADDER_EXIT_FORCE: float = 150.0
# How many pixels from the bottom to disable character's collision shape
const CHARACTER_COLLISION_TOGGLE_TRHESHOLD: = 8.0

@export var character: Player = null

var _climbed_ladder: Area2D = null
var _ladder_bottom: int = 0
var _ladder_top: int = 0
var _ladder_threshold: int = 0
var _is_above_threshold: = false


func on_enter(params: StateParams) -> void:
	assert(character, "Character node cannot be null!")

	character.toggle_hitbox_collider(false)
	passed_ladder_threshold.connect(on_ladder_threshold_passed)
	var is_climbing_down: = false
	if params:
		is_climbing_down = params.climbing_down

	_climbed_ladder = character.ladders_under_player[0] if is_climbing_down else character.touching_ladders[0]
	var ladder_boundaries = _climbed_ladder.get_ladder_boundaries_global()
	_ladder_top = ladder_boundaries.position.y
	_ladder_bottom = ladder_boundaries.end.y
	_ladder_threshold = _ladder_bottom - CHARACTER_COLLISION_TOGGLE_TRHESHOLD

	character.global_position.x = _climbed_ladder.global_position.x
	if params and params.climbing_down:
		character.global_position.y = _ladder_top
		character.toggle_world_collision(false)
		state_machine.change_animation("ladder_edge")

	if params and params.climbing_up:
		state_machine.change_animation("ladder")

	# Reset the primary velocity so the player doesn't move when exiting the state
	character.velocity_primary = Vector2.ZERO
	character.set_world_detector_monitoring(true)
	character.ladder_step_player.playing = true


func on_exit(transition: Transition) -> void:
	character.toggle_hitbox_collider(true)
	character.set_world_detector_monitoring(false)
	passed_ladder_threshold.disconnect(on_ladder_threshold_passed)
	_is_above_threshold = false
	character.ladder_step_player.playing = false


func physics_process(delta: float) -> void:
	var climbing_direction: = Input.get_axis("move_down", "move_up")
	character.velocity = Vector2.UP * climbing_direction * CLIMBING_SPEED
	state_machine.change_animation_speed_scale(0.0)
	if climbing_direction:
		state_machine.change_animation_speed_scale(1.0)

	var should_player_ladder_sfx = true if climbing_direction != 0 else false
	if character.ladder_step_player.playing != should_player_ladder_sfx:
		character.ladder_step_player.playing = should_player_ladder_sfx

	character.move_and_slide()

	if character.global_position.y < _ladder_top + 3:
		state_machine.change_animation("ladder_edge")
	else:
		state_machine.change_animation("ladder")

	var is_above_threshold_old: = _is_above_threshold
	_is_above_threshold = character.global_position.y < _ladder_threshold
	if _is_above_threshold != is_above_threshold_old:
		passed_ladder_threshold.emit(_is_above_threshold)

	if character.global_position.y < _ladder_top:
		character.velocity = Vector2.ZERO
		character.global_position.y = _ladder_top
		character.toggle_world_collision(true)
		state_machine.transition_to("Idle")
		return

	if character.is_on_floor():
		state_machine.transition_to("Idle")
		return


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and not character.collides_with_world:
		character.toggle_world_collision(true)
		var params := StateParams.new()
		params.initiated_jumping = true
		state_machine.transition_to("Air", params)


func on_ladder_threshold_passed(above_threshold: bool) -> void:
	# If the character is above threshold, we want to disable the collision
	character.toggle_world_collision(not above_threshold)


func on_player_exited_ladder() -> void:
	var params = StateParams.new()
	params.initial_impulse = Vector2.UP * LADDER_EXIT_FORCE
	state_machine.transition_to("Air", params)
