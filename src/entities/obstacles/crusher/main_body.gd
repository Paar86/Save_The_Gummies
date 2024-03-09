class_name CrusherMainBody extends AnimatableBody2D

signal body_moved
signal player_detected
signal player_left_detector

var crushed_object_hurtboxes: Array[HurtboxComponent] = []
var crushed_objects: Array[PhysicsBody2D] = []
var player_is_detected: = false

var _origin_position: Vector2
var _crushed_ball_creature: BallCreature

@onready var _collision_shape: = $CollisionShape2D as CollisionShape2D
@onready var _rest_timer: = $RestTimer as Timer


func _ready() -> void:
	_origin_position = position


func get_body_top_edge_global_y() -> float:
	return (global_position.y -
		(_collision_shape.shape as RectangleShape2D).size.y / 2)


func react_to_player_detection() -> void:
	player_is_detected = true


func react_to_player_left_detector() -> void:
	player_is_detected = false


func handle_crushed_objects(is_right_height_func: Callable, check_ceiling: bool = false) -> void:
	for crushed_object in crushed_objects:
		if ((not crushed_object is GameCharacter and not crushed_object is BallCreature)
			or not (is_right_height_func.call(self, crushed_object))
		):
			continue

		var is_floor_ceiling: = false
		if not check_ceiling:
			if ((crushed_object is GameCharacter and not crushed_object.is_on_floor())
				or (crushed_object is BallCreature and not crushed_object.is_on_floor)
			):
				continue

		if check_ceiling:
			if ((crushed_object is GameCharacter and not crushed_object.is_on_ceiling())
				or (crushed_object is BallCreature and not crushed_object.is_on_ceiling)
			):
				continue

		if crushed_object is GameCharacter:
			crushed_object._hurtbox_component.make_damage(999)

		# Only apply the effect once
		if crushed_object is BallCreature and not _crushed_ball_creature:
			_crushed_ball_creature = crushed_object
			if not crushed_object.is_effect_active(Enums.effect.CRUSHED):
				crushed_object.apply_effect(Enums.effect.CRUSHED)

	# Stop crushing a ball creature when it's no longer near the crusher
	if _crushed_ball_creature and not crushed_objects.has(_crushed_ball_creature):
		_crushed_ball_creature.remove_effect(Enums.effect.CRUSHED)
		_crushed_ball_creature = null


func _on_crush_effector_area_body_entered(body: Node2D) -> void:
	if not body is GameCharacter and not body is BallCreature:
		return

	crushed_objects.push_back(body)


func _on_crush_effector_area_body_exited(body: Node2D) -> void:
	if not body is GameCharacter and not body is BallCreature:
		return

	crushed_objects.erase(body)
