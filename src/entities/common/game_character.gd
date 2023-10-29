class_name GameCharacter extends CharacterBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Main movement velocity
var velocity_primary: Vector2 = Vector2.ZERO
# Velocity from external forces (e.g. wind)
var velocity_secondary: Vector2 = Vector2.ZERO

var _applied_effects: Array[Enums.effect] = []
var _applied_movement_modificators: Array[Vector2] = []
#var _combined_movement_modificator: Vector2 = Vector2.ZERO

var velocity_combined: Vector2:
	get:
		return velocity_primary + velocity_secondary


func apply_effect(effect: Enums.effect) -> void:
	if not _applied_effects.has(effect):
		effect_added.emit(effect)

	_applied_effects.append(effect)


func remove_effect(effect: Enums.effect) -> void:
	_applied_effects.erase(effect)

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


func is_effect_active(effect: Enums.effect) -> bool:
	return _applied_effects.has(effect)
