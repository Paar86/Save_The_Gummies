extends State

var cheer_delay: float = 0.0
@export var ball_creature: BallCreature
@onready var _cheer_timer: Timer = $CheerTimer


func on_enter(params: StateParams) -> void:
	ball_creature.pickable = false
	ball_creature.animation_player.stop()
	ball_creature._sprite.frame = 9
	ball_creature.contact_monitor = false
	ball_creature._hitbox_component.toggle_collision(false)

	if cheer_delay > 0:
		await get_tree().create_timer(cheer_delay).timeout

	_apply_impulse_up()


func _apply_impulse_up() -> void:
	ball_creature.apply_impulse(Vector2.UP * 400.0)
	_cheer_timer.start()


func _on_cheer_timer_timeout() -> void:
	_apply_impulse_up()
