class_name GameCharacter extends CharacterBody2D

signal effect_added(effect: Enums.effects)
signal effect_removed(effect: Enums.effects)

var applied_effects: Array[Enums.effects] = []


func apply_effect(effect: Enums.effects) -> void:
	if not applied_effects.has(effect):
		effect_added.emit(effect)

	applied_effects.append(effect)


func remove_effect(effect: Enums.effects) -> void:
	applied_effects.erase(effect)

	if not applied_effects.has(effect):
		effect_removed.emit(effect)


func is_effect_active(effect: Enums.effects) -> bool:
	return applied_effects.has(effect)
