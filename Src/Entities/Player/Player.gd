class_name Player extends CharacterBody2D

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var throw_arrow_pivot: Marker2D = $ThrowArrowPivot
@onready var throw_arrow_sprite: Sprite2D = $ThrowArrowPivot/ThrowArrow
@onready var pickup_transform: RemoteTransform2D = $PickupTransform2D

var pickable_objects: Array[RigidBody2D] = []
var hold_object: BallCreature = null

var aim_direction: Vector2:
	get:
		return (throw_arrow_sprite.global_position - throw_arrow_pivot.global_position).normalized()


func _ready() -> void:
	Events.player_direction_changed.connect(on_player_direction_changed)
	Events.player_aiming_requested.connect(on_player_aiming_requested)
	Events.player_aiming_called_off.connect(on_player_aiming_called_off)


func _exit_tree() -> void:
	Events.player_direction_changed.disconnect(on_player_direction_changed)
	Events.player_aiming_requested.disconnect(on_player_aiming_requested)
	Events.player_aiming_called_off.disconnect(on_player_aiming_called_off)


func on_player_direction_changed(new_direction: float) -> void:
	# Reversing the player sprite
	player_sprite.flip_h = true if new_direction < 0 else false

	# Reversing the pickup position
	pickup_transform.position.x = abs(pickup_transform.position.x) * new_direction

	# Reversing the throw arrow
	throw_arrow_pivot.change_direction(new_direction)


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
