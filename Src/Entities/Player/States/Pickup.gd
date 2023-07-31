extends State

@export var character: CharacterBody2D

const PICKUP_SPEED_MODIFIER: = 10.0

var picked_object: RigidBody2D
var picked_object_original_position: = Vector2.ZERO
var elapsed_time: float = 0.0


func on_enter(params: StateParams) -> void:
	if character.pickable_objects.size() == 0:
		state_machine.transition_to("Idle")
		return

	picked_object = character.pickable_objects.pop_back() as RigidBody2D
	picked_object_original_position = picked_object.global_position
	character.hold_object = picked_object
	character.hold_object.set_deferred("freeze", true)

	elapsed_time = 0.0
	character.velocity = Vector2.ZERO


func physics_process(delta: float) -> void:
	elapsed_time += delta * PICKUP_SPEED_MODIFIER
	elapsed_time = minf(elapsed_time, 1.0)

	picked_object.global_position = picked_object_original_position.lerp(character.pickup_transform.global_position, elapsed_time)
	if picked_object.global_position == character.pickup_transform.global_position:
		state_machine.transition_to("Carry")
		return
