class_name Player extends GameCharacter

signal lives_changed(new_value: int)

var pickable_objects: Array[RigidBody2D] = []
var whistle_affected_bodies: Array[PhysicsBody2D] = []
var touching_ladders: Array[Area2D] = []
var ladders_under_player: Array[Area2D] = []
var hold_object: BallCreature = null

var aim_direction: Vector2:
	get:
		return (_throw_arrow_sprite.global_position - _throw_arrow_pivot.global_position).normalized()

# in seconds
var _sprite_flash_frequency: float = 0.10
var _sprite_flash_duration: float = 3.0
var _is_flashing: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pickup_transform: RemoteTransform2D = $PickupTransform2D
@onready var _player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _throw_arrow_pivot: Marker2D = $ThrowArrowPivot
@onready var _throw_arrow_sprite: Sprite2D = $ThrowArrowPivot/SpriteContainer/ThrowArrowSprite
@onready var _ladder_detector_left: RayCast2D = $Raycasts/LadderDetectorLeft
@onready var _ladder_detector_middle: RayCast2D = $Raycasts/LadderDetectorMiddle
@onready var _ladder_detector_right: RayCast2D = $Raycasts/LadderDetectorRight
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	super._ready()

	Events.player_direction_changed.connect(_on_player_direction_changed)
	Events.player_aiming_requested.connect(_on_player_aiming_requested)
	Events.player_aiming_called_off.connect(_on_player_aiming_called_off)

	_hurtbox_component.lives_changed.connect(on_damage_taken)
	_hurtbox_component.lives_depleted.connect(on_lives_depleted)


func _process(delta: float) -> void:
	ladders_under_player = []

	var ladder_detector_left_collider = _ladder_detector_left.get_collider()
	var ladder_detector_middle_collider = _ladder_detector_middle.get_collider()
	var ladder_detector_right_collider = _ladder_detector_right.get_collider()

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


func toggle_hitbox_collider(value: bool) -> void:
	_hitbox_component.monitoring = value


func toggle_hurtbox_collider(value: bool) -> void:
	_hurtbox_component.set_deferred("monitorable", value)


func _on_player_direction_changed(new_direction: float) -> void:
	# Reversing the player sprite
	_player_animated_sprite.scale.x = abs(_player_animated_sprite.scale.x) * new_direction

	# Reversing the pickup position
	pickup_transform.position.x = abs(pickup_transform.position.x) * new_direction

	# Position of the throw arrow
	_throw_arrow_pivot.position.x = abs(_throw_arrow_pivot.position.x) * new_direction


func _on_player_aiming_requested() -> void:
	_throw_arrow_pivot.enable()


func _on_player_aiming_called_off() -> void:
	_throw_arrow_pivot.disable()


func get_current_lives() -> int:
	return _hurtbox_component.lives


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


func on_damage_taken(current_lives: int) -> void:
	lives_changed.emit(current_lives)

	toggle_hurtbox_collider(false)
	_is_flashing = true
	get_tree().create_timer(_sprite_flash_duration).timeout.connect(on_flash_duration_expired)

	while(_is_flashing):
		_player_animated_sprite.visible = !_player_animated_sprite.visible
		await get_tree().create_timer(_sprite_flash_frequency).timeout

	_player_animated_sprite.visible = true
	toggle_hurtbox_collider(true)


func on_flash_duration_expired() -> void:
	_is_flashing = false


func on_lives_depleted() -> void:
	_generate_death_scene(_player_animated_sprite.global_position)
	queue_free()


func _on_whistle_area_body_entered(body: Node2D) -> void:
	if not body is GameCharacter and not body is BallCreature:
		return

	whistle_affected_bodies.append(body)


func _on_whistle_area_body_exited(body: Node2D) -> void:
	if not whistle_affected_bodies.has(body):
		return

	whistle_affected_bodies.erase(body)
