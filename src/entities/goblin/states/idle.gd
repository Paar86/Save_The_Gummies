extends State

@export var move_state: GoblinMoveState = null
@onready var _idle_timer: Timer = $IdleTimer


func _ready() -> void:
	_idle_timer.timeout.connect(on_idle_timer_timeout)


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("idle")
	# Setting to 0.0 so the Goblin is not moving
	move_state.horizontal_speed = 0.0
	_idle_timer.start()

	if not move_state.can_attack:
		move_state.can_attack_timer.start()


func on_exit() -> void:
	_idle_timer.stop()
	move_state.horizontal_speed = move_state.HORIZONTAL_SPEED_DEFAULT


func propagate_effects(effects: Array[String]) -> void:
	move_state.propagate_effects(effects)


func on_idle_timer_timeout() -> void:
	state_machine.transition_to("Walk")
