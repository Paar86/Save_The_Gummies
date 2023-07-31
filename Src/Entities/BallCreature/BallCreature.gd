class_name BallCreature extends RigidBody2D

var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable
