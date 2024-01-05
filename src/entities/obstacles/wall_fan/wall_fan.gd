@tool
class_name WallFan extends Area2D

@export var wind_strength: = 35.0


func _on_body_entered(body: Node2D) -> void:
	if body is GameCharacter or body is BallCreature:
		var wind_velocity := Vector2(transform.x.x * wind_strength, 0.0)
		body.apply_movement_modificator(wind_velocity)
		body.apply_effect(Enums.effect.WIND)


func _on_body_exited(body: Node2D) -> void:
	if body is GameCharacter or body is BallCreature:
		var wind_velocity := Vector2(transform.x.x * wind_strength, 0.0)
		body.remove_movement_modificator(wind_velocity)
		body.remove_effect(Enums.effect.WIND)
