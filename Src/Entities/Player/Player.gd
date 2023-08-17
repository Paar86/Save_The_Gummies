class_name Player extends CharacterBody2D

@onready var player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_arrow_pivot: Marker2D = $ThrowArrowPivot
@onready var throw_arrow_sprite: Sprite2D = $ThrowArrowPivot/SpriteContainer/ThrowArrowSprite
@onready var pickup_transform: RemoteTransform2D = $PickupTransform2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var pickable_objects: Array[RigidBody2D] = []
var hold_object: BallCreature = null

var aim_direction: Vector2:
	get:
		return (throw_arrow_sprite.global_position - throw_arrow_pivot.global_position).normalized()


func _ready() -> void:
	Events.player_direction_changed.connect(on_player_direction_changed)
	Events.player_aiming_requested.connect(on_player_aiming_requested)
	Events.player_aiming_called_off.connect(on_player_aiming_called_off)


func on_player_direction_changed(new_direction: float) -> void:
	# Reversing the player sprite
	player_animated_sprite.scale.x = abs(player_animated_sprite.scale.x) * new_direction

	# Reversing the pickup position
	pickup_transform.position.x = abs(pickup_transform.position.x) * new_direction

	# Position of the throw arrow
	throw_arrow_pivot.position.x = abs(throw_arrow_pivot.position.x) * new_direction


func on_player_aiming_requested() -> void:
	throw_arrow_pivot.enable()


func on_player_aiming_called_off() -> void:
	throw_arrow_pivot.disable()


func on_pickup_detector_body_entered(body: PhysicsBody2D) -> void:
	if body is RigidBody2D and not pickable_objects.has(body):
		if (body as BallCreature).pickable:
			pickable_objects.push_back(body)


func on_pickup_detector_body_exited(body: PhysicsBody2D) -> void:
	if body is RigidBody2D and pickable_objects.has(body):
		pickable_objects.erase(body)
