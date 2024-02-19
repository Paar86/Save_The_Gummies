extends CrusherState

var _acceleration: = 180.0
var _max_speed: = 120.0
var _vertical_velocity: = 0.0
var _crushed_ball_creature: BallCreature


func on_exit(transition: Transition) -> void:
	_vertical_velocity = 0.0


func physics_process(delta: float) -> void:
	crusher_body.handle_crushed_objects(
		func(crusher_body: CrusherMainBody, crushed_object: PhysicsBody2D) -> bool:
		return crushed_object.global_position.y > crusher_body.global_position.y,
	)

	_vertical_velocity += _acceleration * delta
	_vertical_velocity = clampf(_vertical_velocity, 0.0, _max_speed)
	var collision: = crusher_body.move_and_collide(_vertical_velocity * Vector2.DOWN * delta, false, 0.01)
	crusher_body.body_moved.emit()

	# Check if the collider is baked collision shape
	if collision and collision.get_collider() is StaticBody2D:
			state_machine.transition_to("Resting")
