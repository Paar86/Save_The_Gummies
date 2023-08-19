class_name Player extends CharacterBody2D

@onready var player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var throw_arrow_pivot: Marker2D = $ThrowArrowPivot
@onready var throw_arrow_sprite: Sprite2D = $ThrowArrowPivot/SpriteContainer/ThrowArrowSprite
@onready var pickup_transform: RemoteTransform2D = $PickupTransform2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ladder_detector_left: RayCast2D = $Raycasts/LadderDetectorLeft
@onready var ladder_detector_middle: RayCast2D = $Raycasts/LadderDetectorMiddle
@onready var ladder_detector_right: RayCast2D = $Raycasts/LadderDetectorRight

var pickable_objects: Array[RigidBody2D] = []
var touching_ladders: Array[Area2D] = []
var ladders_under_player: Array[Area2D] = []
var hold_object: BallCreature = null

var aim_direction: Vector2:
	get:
		return (throw_arrow_sprite.global_position - throw_arrow_pivot.global_position).normalized()


func _ready() -> void:
	Events.player_direction_changed.connect(on_player_direction_changed)
	Events.player_aiming_requested.connect(on_player_aiming_requested)
	Events.player_aiming_called_off.connect(on_player_aiming_called_off)


func _process(delta: float) -> void:
	ladders_under_player = []

	var ladder_detector_left_collider = ladder_detector_left.get_collider()
	var ladder_detector_middle_collider = ladder_detector_middle.get_collider()
	var ladder_detector_right_collider = ladder_detector_right.get_collider()

	if ladder_detector_left_collider and ladder_detector_left_collider.is_in_group("Ladders"):
		if not ladders_under_player.has(ladder_detector_left_collider):
			ladders_under_player.append(ladder_detector_left_collider)

	if ladder_detector_middle_collider and ladder_detector_middle_collider.is_in_group("Ladders"):
		if not ladders_under_player.has(ladder_detector_middle_collider):
			ladders_under_player.append(ladder_detector_middle_collider)

	if ladder_detector_right_collider and ladder_detector_right_collider.is_in_group("Ladders"):
		if not ladders_under_player.has(ladder_detector_right_collider):
			ladders_under_player.append(ladder_detector_right_collider)


func toggle_world_collision(value: bool) -> void:
	set_collision_mask_value(1, value)


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


func on_objects_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ladders"):
		touching_ladders.append(area)


func on_objects_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Ladders"):
		touching_ladders.erase(area)
		Events.player_exited_ladder.emit()
