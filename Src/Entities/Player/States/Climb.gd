extends State

const CLIMBING_SPEED: float = 20.0
const LADDER_EXIT_FORCE: float = 150.0

@export var character: Player = null


func on_enter(params: StateParams) -> void:
	assert(character, "Character node cannot be null!")

	Events.player_exited_ladder.connect(on_player_exited_ladder)

	var ladder: Area2D = character.touching_ladders[0]
	character.global_position.x = ladder.global_position.x
	state_machine.change_animation("ladder")


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		var new_params := StateParams.new()
		new_params.initiated_jumping = true
		state_machine.transition_to("Air", new_params)
		return


func on_exit() -> void:
	Events.player_exited_ladder.disconnect(on_player_exited_ladder)


func physics_process(delta: float) -> void:
	var climbing_direction: = Input.get_axis("move_down", "move_up")
	character.velocity = Vector2.UP * climbing_direction * CLIMBING_SPEED
	state_machine.change_animation_speed_scale(0.0)
	if climbing_direction:
		state_machine.change_animation_speed_scale(1.0)

	character.move_and_slide()

	if character.is_on_floor():
		state_machine.transition_to("Idle")
		return


func on_player_exited_ladder() -> void:
	var params = StateParams.new()
	params.initial_impulse = Vector2.UP * LADDER_EXIT_FORCE
	state_machine.transition_to("Air", params)
