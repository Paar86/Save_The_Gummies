extends State

@export var move_state: GoblinMoveState = null
@onready var _walk_timer: Timer = $WalkTimer


func _ready() -> void:
	_walk_timer.timeout.connect(on_walk_timer_timeout)


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("walk")
	_walk_timer.start()


func on_exit() -> void:
	_walk_timer.stop()


func physics_process(delta: float) -> void:
	var real_velocity = move_state.character.get_real_velocity()
	var animation_speed_scale = abs(real_velocity.length()) / move_state.horizontal_speed
	state_machine.change_animation_speed_scale(animation_speed_scale)

	move_state.physics_process(delta)


func propagate_effects(effects: Array[String]) -> void:
	move_state.propagate_effects(effects)


func on_walk_timer_timeout() -> void:
	state_machine.transition_to("Idle")
