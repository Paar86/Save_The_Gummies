extends State

@export var ball_creature: BallCreature

var _idle_animations_weights = {
	"blinking": 0.75,
	"looking_around": 0.25,
}

@onready var _animation_delay_timer: Timer = $AnimationDelayTimer
@onready var _next_animation_delay_timer: Timer = $NextAnimationDelayTimer


func _ready() -> void:
	_animation_delay_timer.connect("timeout", _on_animation_delay_timeout)
	_next_animation_delay_timer.connect("timeout", _on_next_animation_delay_timeout)


func on_enter(params: StateParams) -> void:
	ball_creature.animation_player.connect("animation_finished", _on_animation_finished)
	_animation_delay_timer.start()


func on_exit() -> void:
	_animation_delay_timer.stop()
	_next_animation_delay_timer.stop()
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
	_next_animation_delay_timer.start()


func _on_next_animation_delay_timeout() -> void:
	var weight = randf()
	var next_animation_name = "blinking"
	for animation in _idle_animations_weights:
		if weight >= _idle_animations_weights[animation]:
			next_animation_name = animation
			break

	ball_creature.animation_player.play(next_animation_name)


func _on_animation_finished(animation_name: StringName) -> void:
	_next_animation_delay_timer.wait_time = randf_range(0.15, 3.0)
	_next_animation_delay_timer.start()
