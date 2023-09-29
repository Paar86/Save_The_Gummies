class_name BallCreature extends RigidBody2D

var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable

var _damp_default: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
var _applied_effects: Array[Enums.effect] = []

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func apply_effect(effect: Enums.effect) -> void:
	if not _applied_effects.has(effect):
		effect_added(effect)

	_applied_effects.append(effect)


func remove_effect(effect: Enums.effect) -> void:
	_applied_effects.erase(effect)

	if not _applied_effects.has(effect):
		effect_removed(effect)


func is_effect_active(effect: Enums.effect) -> bool:
	return _applied_effects.has(effect)


func disable_collision() -> void:
	_collision_shape.set_deferred("disabled", true)


func enable_collision() -> void:
	_collision_shape.set_deferred("disabled", false)


func effect_added(effect: Enums.effect) -> void:
	linear_damp = 5
	physics_material_override.bounce = 0.0


func effect_removed(effect: Enums.effect) -> void:
	linear_damp = _damp_default
	physics_material_override.bounce = 0.4
