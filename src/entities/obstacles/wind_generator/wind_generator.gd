extends StaticBody2D

const WIND_STRENGTH: float = 50.0

func _on_wind_area_body_entered(body: Node2D) -> void:
	if body is GameCharacter:
		var wind_velocity := Vector2(transform.x.x * WIND_STRENGTH, 0.0)
		body.apply_movement_modificator(wind_velocity)
		print("Applying velocity " + str(wind_velocity))


func _on_wind_area_body_exited(body: Node2D) -> void:
	if body is GameCharacter:
		var wind_velocity := Vector2(transform.x.x * WIND_STRENGTH, 0.0)
		body.remove_movement_modificator(wind_velocity)
