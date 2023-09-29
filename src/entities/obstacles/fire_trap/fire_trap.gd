extends Node2D

@onready var _inactive_timer: Timer = $InactiveTimer
@onready var _telegraph_timer: Timer = $TelegraphTimer
@onready var _active_timer: Timer = $ActiveTimer
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D


func toggle_collision(value: bool) -> void:
	_hitbox_collision.set_deferred("disabled", !value)


func _on_inactive_timer_timeout() -> void:
	_animated_sprite.play("telegraph")
	_telegraph_timer.start()


func _on_telegraph_timer_timeout() -> void:
	_animated_sprite.play("active")
	toggle_collision(true)
	_active_timer.start()


func _on_active_timer_timeout() -> void:
	_animated_sprite.play("inactive")
	toggle_collision(false)
	_inactive_timer.start()
