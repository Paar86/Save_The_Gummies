class_name EffectsApplierComponent extends Node

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Velocity from external forces (e.g. wind)
var velocity_secondary: Vector2 = Vector2.ZERO

var _applied_effects: Array[Enums.effect] = []
# TODO: This could be renamed to 'movement_adders'
# and there could also be 'movement_reducers', e.g. when glued
var _applied_movement_modificators: Array[Vector2] = []


func apply_effect(effect: Enums.effect) -> void:
	# We should only react if there is no other effect of the same type
	if not _applied_effects.has(effect):
		effect_added.emit(effect)

	_applied_effects.append(effect)


func remove_effect(effect: Enums.effect) -> void:
	_applied_effects.erase(effect)

	# We should react only if there is no other effect of the same type
	if not _applied_effects.has(effect):
		effect_removed.emit(effect)


func apply_movement_modificator(modificator: Vector2) -> void:
	if not _applied_movement_modificators.has(modificator):
		velocity_secondary += modificator

	_applied_movement_modificators.push_back(modificator)


func remove_movement_modificator(modificator: Vector2) -> void:
	_applied_movement_modificators.erase(modificator)

	var occurrences = _applied_movement_modificators.count(modificator)
	if occurrences == 0:
		velocity_secondary -= modificator


# Removes all occurences of a specified effect
func flush_effect(effect: Enums.effect) -> void:
	_applied_effects = _applied_effects.filter(func(applied_effect): return applied_effect != effect)


func is_effect_active(effect: Enums.effect) -> bool:
	return _applied_effects.has(effect)
