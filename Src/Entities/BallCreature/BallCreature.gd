class_name BallCreature extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable


func disable_collision() -> void:
	collision_shape.set_deferred("disabled", true)


func enable_collision() -> void:
	collision_shape.set_deferred("disabled", false)
