extends CrusherState

var _ascending_speed: = 25.0


func physics_process(delta: float) -> void:
	for crushed_object in crusher_body.crushed_objects:
		if not crushed_object is GameCharacter:
			continue

		var crushed_character: = crushed_object as GameCharacter
		if crushed_character.is_on_ceiling() and crushed_character.global_position.y < crusher_body.global_position.y:
			crushed_character._hurtbox_component.make_damage(999)

	var collider: = crusher_body.move_and_collide(_ascending_speed * Vector2.UP * delta)
	crusher_body.body_moved.emit()

	if collider and collider.get_collider() is StaticBody2D:
		state_machine.transition_to("Idle")
		return

	if crusher_body.position.y < crusher_body._origin_position.y:
		crusher_body.set_deferred("position", crusher_body._origin_position)
		state_machine.transition_to("Idle")
