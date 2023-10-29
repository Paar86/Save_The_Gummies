extends StaticBody2D

const WIND_STRENGTH: float = 50.0


func _on_wind_area_body_entered(body: Node2D) -> void:
	if body is GameCharacter or body is BallCreature:
		var wind_velocity := Vector2(transform.x.x * WIND_STRENGTH, 0.0)
		body.apply_movement_modificator(wind_velocity)
		body.apply_effect(Enums.effect.WIND)


func _on_wind_area_body_exited(body: Node2D) -> void:
	if body is GameCharacter or body is BallCreature:
		var wind_velocity := Vector2(transform.x.x * WIND_STRENGTH, 0.0)
		body.remove_movement_modificator(wind_velocity)
		body.remove_effect(Enums.effect.WIND)
