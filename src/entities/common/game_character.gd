class_name GameCharacter extends CharacterBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Main movement velocity
var velocity_primary: Vector2 = Vector2.ZERO

# Properties
var velocity_secondary: Vector2:
	get:
		return _effects_applier_component.velocity_secondary

var velocity_combined: Vector2:
	get:
		return velocity_primary + velocity_secondary

# Nodes
@onready var _effects_applier_component: EffectsApplierComponent = $EffectsApplierComponent


func _ready() -> void:
	# Delegating signals from effect applier component for use in FSM
	_effects_applier_component.effect_added.connect(func(effect: Enums.effect) -> void: effect_added.emit(effect))
	_effects_applier_component.effect_removed.connect(func(effect: Enums.effect) -> void: effect_removed.emit(effect))


# Proxy calls to EffectsApplierComponent
func apply_effect(effect: Enums.effect) -> void:
	_effects_applier_component.apply_effect(effect)


func remove_effect(effect: Enums.effect) -> void:
	_effects_applier_component.remove_effect(effect)


func apply_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.apply_movement_modificator(modificator)


func remove_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.remove_movement_modificator(modificator)


func is_effect_active(effect: Enums.effect) -> bool:
	return _effects_applier_component.is_effect_active(effect)
