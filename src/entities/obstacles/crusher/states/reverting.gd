extends CrusherState

var _ascending_speed: = 25.0
var _crushed_ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
	crusher_body.play_reverting_sfx()


func on_exit(transition: Transition) -> void:
	crusher_body.stop_reverting_sfx()


func physics_process(delta: float) -> void:
	crusher_body.handle_crushed_objects(
		func(crusher_body: CrusherMainBody, crushed_object: PhysicsBody2D) -> bool:
			return crushed_object.global_position.y < crusher_body.global_position.y,
		true
	)

	var collider: = crusher_body.move_and_collide(_ascending_speed * Vector2.UP * delta, false, 0.0)
	crusher_body.body_moved.emit()

	if collider and collider.get_collider() is StaticBody2D:
		state_machine.transition_to("Idle")
		return

	if crusher_body.position.y < crusher_body._origin_position.y:
		crusher_body.set_deferred("position", crusher_body._origin_position)
		crusher_body.body_moved.emit()
		state_machine.transition_to("Idle")
