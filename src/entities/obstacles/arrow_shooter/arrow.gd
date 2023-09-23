class_name Arrow extends Area2D

const SPEED_DEFAULT: float = 120.0

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var self_destruct_timer: Timer = $SelfDestructTimer
var speed: float = SPEED_DEFAULT


func _ready() -> void:
	hitbox_component.damage_made.connect(on_damage_made)
	hurtbox_component.effects_propagated.connect(on_effects_propagated)


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func start_self_destruct_countdown() -> void:
	hurtbox_component.set_collision_layer_value(3, false)
	hitbox_component.toggle_collision(false)
	self_destruct_timer.start()
	animated_sprite.stop()

	await self_destruct_timer.timeout
	queue_free()


# Collision with world
func _on_body_entered(body: Node2D) -> void:
	speed = 0.0
	start_self_destruct_countdown()


# Damage made to player
func on_damage_made(amount: int) -> void:
	queue_free()


# Damage from player/ball
func on_effects_propagated(effects: Array[String]) -> void:
	# Stomp from player
	if effects.has("stun"):
		queue_free()
