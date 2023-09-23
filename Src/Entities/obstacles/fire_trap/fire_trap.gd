extends Node2D

@onready var inactive_timer: Timer = $InactiveTimer
@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var active_timer: Timer = $ActiveTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D


func toggle_collision(value: bool) -> void:
	hitbox_collision.set_deferred("disabled", !value)


func _on_inactive_timer_timeout() -> void:
	animated_sprite.play("telegraph")
	telegraph_timer.start()


func _on_telegraph_timer_timeout() -> void:
	animated_sprite.play("active")
	toggle_collision(true)
	active_timer.start()


func _on_active_timer_timeout() -> void:
	animated_sprite.play("inactive")
	toggle_collision(false)
	inactive_timer.start()
