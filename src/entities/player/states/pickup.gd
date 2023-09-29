extends State

const PICKUP_SPEED_MODIFIER: = 10.0

@export var character: CharacterBody2D

var _picked_object: RigidBody2D
var _picked_object_original_position: = Vector2.ZERO
var _elapsed_time: float = 0.0


func on_enter(params: StateParams) -> void:
	if character.pickable_objects.size() == 0:
		state_machine.transition_to("Idle")
		return

	_picked_object = character.pickable_objects.pop_back() as RigidBody2D
	_picked_object_original_position = _picked_object.global_position
	_picked_object.set_deferred("freeze", true)
	_picked_object.disable_collision()

	character.hold_object = _picked_object

	_elapsed_time = 0.0
	character.velocity = Vector2.ZERO


func physics_process(delta: float) -> void:
	_elapsed_time += delta * PICKUP_SPEED_MODIFIER
	_elapsed_time = minf(_elapsed_time, 1.0)

	_picked_object.global_position = _picked_object_original_position.lerp(character.pickup_transform.global_position, _elapsed_time)
	if _picked_object.global_position == character.pickup_transform.global_position:
		state_machine.transition_to("CarryIdle")
		return
