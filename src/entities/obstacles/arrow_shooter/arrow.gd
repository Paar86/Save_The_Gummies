class_name Arrow extends Area2D

const SPEED_DEFAULT: float = 120.0
const WORLD_WAIT_TIME: float = 2.0
const PLAYER_WAIT_TIME: float = 2.0

var _speed: float = SPEED_DEFAULT

@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _self_destruct_timer: Timer = $SelfDestructTimer


func _ready() -> void:
	_hitbox_component.damage_made.connect(on_damage_made)
	_hurtbox_component.effects_propagated.connect(_on_effects_propagated)


func _physics_process(delta: float) -> void:
	position += transform.x * _speed * delta


func start_self_destruct_countdown(wait_time) -> void:
	_hurtbox_component.set_collision_layer_value(3, false)
	_hitbox_component.toggle_collision(false)
	_self_destruct_timer.wait_time = wait_time
	_self_destruct_timer.start()
	_animated_sprite.stop()

	await _self_destruct_timer.timeout
	queue_free()


# Collision with world
func _on_body_entered(body: Node2D) -> void:
	_speed = 0.0
	start_self_destruct_countdown(WORLD_WAIT_TIME)


# Damage made to player
func on_damage_made(amount: int, area: Area2D) -> void:
	var transform_matrix = global_transform
	get_parent().remove_child(self)
	area.add_child(self)
	global_transform = transform_matrix

	_speed = 0.0
	start_self_destruct_countdown(PLAYER_WAIT_TIME)


# Damage from player/ball
func _on_effects_propagated(effects: Array[String]) -> void:
	# Stomp from player
	if effects.has("stun"):
		queue_free()
