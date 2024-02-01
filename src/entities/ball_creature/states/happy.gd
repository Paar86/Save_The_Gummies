extends State

const HAPPY_JUMP_STRENGTH: = 500.0

@export var ball_creature: BallCreature

@onready var _jump_timer: = $JumpTimer as Timer


func on_enter(params: StateParams) -> void:
	ball_creature.animation_player.play("happy")
	_jump_timer.timeout.connect(_on_jump_timer_timeout)


func on_exit(transition: Transition) -> void:
	_jump_timer.timeout.disconnect(_on_jump_timer_timeout)
	_jump_timer.stop()


func physics_process(delta: float) -> void:
	if not ball_creature.happy_mode_locked:
		state_machine.transition_to("Idle")
		return

	if ball_creature.is_on_floor and not _jump_timer.time_left:
		_jump_timer.wait_time = randf_range(3.0, 4.0)
		_jump_timer.start()


func _on_jump_timer_timeout() -> void:
	ball_creature.apply_impulse(Vector2.UP * HAPPY_JUMP_STRENGTH)
