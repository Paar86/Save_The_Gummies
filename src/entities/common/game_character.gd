class_name GameCharacter extends CharacterBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

var _applied_effects: Array[Enums.effect] = []


func apply_effect(effect: Enums.effect) -> void:
	if not _applied_effects.has(effect):
		effect_added.emit(effect)

	_applied_effects.append(effect)


func remove_effect(effect: Enums.effect) -> void:
	_applied_effects.erase(effect)

	if not _applied_effects.has(effect):
		effect_removed.emit(effect)


func is_effect_active(effect: Enums.effect) -> bool:
	return _applied_effects.has(effect)
