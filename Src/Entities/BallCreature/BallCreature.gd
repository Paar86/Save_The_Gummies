class_name BallCreature extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var damp_default: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")

var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable

var applied_effects: Array[Enums.effects] = []


func apply_effect(effect: Enums.effects) -> void:
	if not applied_effects.has(effect):
		effect_added(effect)

	applied_effects.append(effect)


func remove_effect(effect: Enums.effects) -> void:
	applied_effects.erase(effect)

	if not applied_effects.has(effect):
		effect_removed(effect)


func is_effect_active(effect: Enums.effects) -> bool:
	return applied_effects.has(effect)


func disable_collision() -> void:
	collision_shape.set_deferred("disabled", true)


func enable_collision() -> void:
	collision_shape.set_deferred("disabled", false)


func effect_added(effect: Enums.effects) -> void:
	linear_damp = 5


func effect_removed(effect: Enums.effects) -> void:
	linear_damp = damp_default
