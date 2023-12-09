extends State

const BLINKING_DEFAULT_TIME: = 3.0

@export var ball_creature: BallCreature
@onready var _animation_delay_timer: Timer = $AnimationDelayTimer
@onready var _blinking_delay_timer: Timer = $BlinkingDelayTimer


func _ready() -> void:
	_animation_delay_timer.connect("timeout", _on_animation_delay_timeout)
	_blinking_delay_timer.connect("timeout", _on_blinking_delay_timeout)


func on_enter(params: StateParams) -> void:
	ball_creature.animation_player.connect("animation_finished", _on_animation_finished)
	_animation_delay_timer.start()


func on_exit() -> void:
	_animation_delay_timer.stop()
	_blinking_delay_timer.stop()
	_blinking_delay_timer.wait_time = BLINKING_DEFAULT_TIME
	ball_creature.animation_player.disconnect("animation_finished", _on_animation_finished)
	ball_creature.animation_player.play("RESET")


func physics_process(delta: float) -> void:
	if not ball_creature.is_on_floor:
		state_machine.transition_to("Air")
		return

	if not ball_creature.sleeping:
		state_machine.transition_to("Rolling")
		return


func _on_animation_delay_timeout() -> void:
	ball_creature.animation_player.play("idle")
	_blinking_delay_timer.start()


func _on_blinking_delay_timeout() -> void:
	ball_creature.animation_player.play("blinking")


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "blinking":
		_blinking_delay_timer.wait_time = randf_range(0.15, 3.0)
		_blinking_delay_timer.start()
