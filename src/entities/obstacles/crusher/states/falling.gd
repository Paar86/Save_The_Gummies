extends CrusherState

var _acceleration: = 180.0
var _max_speed: = 120.0
var _vertical_velocity: = 0.0


func on_exit(transition: Transition) -> void:
	_vertical_velocity = 0.0


func physics_process(delta: float) -> void:
	for crushed_object in crusher_body.crushed_objects:
		if not crushed_object is GameCharacter:
			continue

		var crushed_character: = crushed_object as GameCharacter
		if crushed_character.is_on_floor() and crushed_character.global_position.y > crusher_body.global_position.y:
			crushed_character._hurtbox_component.make_damage(999)

	_vertical_velocity += _acceleration * delta
	_vertical_velocity = clampf(_vertical_velocity, 0.0, _max_speed)
	var collision: = crusher_body.move_and_collide(_vertical_velocity * Vector2.DOWN * delta, false, 0.01)
	crusher_body.body_moved.emit()

	# Check if the collider is baked collision shape
	if collision and collision.get_collider() is StaticBody2D:
			state_machine.transition_to("Resting")
