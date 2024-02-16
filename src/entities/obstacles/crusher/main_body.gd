class_name CrusherMainBody extends AnimatableBody2D

signal body_moved
signal player_detected
signal player_left_detector

var crushed_object_hurtboxes: Array[HurtboxComponent] = []
var crushed_objects: Array[PhysicsBody2D] = []
var player_is_detected: = false

var _origin_position: Vector2

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


func _on_crush_effector_area_body_entered(body: Node2D) -> void:
	if not body is GameCharacter and not body is BallCreature:
		return

	crushed_objects.push_back(body)


func _on_crush_effector_area_body_exited(body: Node2D) -> void:
	if not body is GameCharacter and not body is BallCreature:
		return

	crushed_objects.erase(body)
