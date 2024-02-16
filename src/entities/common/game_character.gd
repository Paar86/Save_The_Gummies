class_name GameCharacter extends CharacterBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Main movement velocity
var velocity_primary: Vector2 = Vector2.ZERO
var _death_animation: PackedScene = preload("res://src/effects/death/death_smoke.tscn")
var _star_explosion: PackedScene = preload("res://src/effects/death/star_explosion.tscn")

# Properties
var velocity_secondary: Vector2:
	get:
		# TODO: This should probably be implemented more elegantly
		var modificator: = 1.0
		if is_effect_active(Enums.effect.GLUED):
			modificator = 0.5

		return _effects_applier_component.velocity_secondary * modificator

var velocity_combined: Vector2:
	get:
		return velocity_primary + velocity_secondary

# Nodes
@onready var _effects_applier_component: EffectsApplierComponent = $EffectsApplierComponent
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	# Delegating signals from effect applier component for use in FSM
	_effects_applier_component.effect_added.connect(func(effect: Enums.effect) -> void: effect_added.emit(effect))
	_effects_applier_component.effect_removed.connect(func(effect: Enums.effect) -> void: effect_removed.emit(effect))


# Proxy calls to EffectsApplierComponent
func apply_effect(effect: Enums.effect) -> void:
	_effects_applier_component.apply_effect(effect)


func remove_effect(effect: Enums.effect) -> void:
	_effects_applier_component.remove_effect(effect)


func flush_effect(effect: Enums.effect) -> void:
	_effects_applier_component.flush_effect(effect)


func flush_all_effects() -> void:
	_effects_applier_component.flush_all_effects()


func flush_movement_modificators() -> void:
	_effects_applier_component.flush_movement_modificators()


func apply_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.apply_movement_modificator(modificator)


func remove_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.remove_movement_modificator(modificator)


func is_effect_active(effect: Enums.effect) -> bool:
	return _effects_applier_component.is_effect_active(effect)


func propagate_whistle(source_body: GameCharacter) -> void:
	pass


func _generate_death_scene(origin_global_position: Vector2) -> void:
	var scenes_array: = [
		_death_animation.instantiate(),
		_star_explosion.instantiate(),
	]

	for effect_scene in scenes_array:
		effect_scene.global_position = origin_global_position
		get_parent().add_child(effect_scene)
