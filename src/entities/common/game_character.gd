class_name GameCharacter extends CharacterBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

var applied_effects: Array[Enums.effect] = []


func apply_effect(effect: Enums.effect) -> void:
	if not applied_effects.has(effect):
		effect_added.emit(effect)

	applied_effects.append(effect)


func remove_effect(effect: Enums.effect) -> void:
	applied_effects.erase(effect)

	if not applied_effects.has(effect):
		effect_removed.emit(effect)


func is_effect_active(effect: Enums.effect) -> bool:
	return applied_effects.has(effect)
