class_name BallCreature extends RigidBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable

var _damp_default: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _effects_applier_component: EffectsApplierComponent = $EffectsApplierComponent


func _ready() -> void:
	_effects_applier_component.effect_added.connect(func(effect: Enums.effect) -> void: effect_added.emit(effect))
	_effects_applier_component.effect_removed.connect(func(effect: Enums.effect) -> void: effect_removed.emit(effect))

	effect_added.connect(_on_effect_added)
	effect_removed.connect(_on_effect_removed)


func _physics_process(delta: float) -> void:
	if _effects_applier_component.velocity_secondary != Vector2.ZERO:
		apply_central_force(_effects_applier_component.velocity_secondary)


func apply_effect(effect: Enums.effect) -> void:
	_effects_applier_component.apply_effect(effect)


func remove_effect(effect: Enums.effect) -> void:
	_effects_applier_component.remove_effect(effect)


func is_effect_active(effect: Enums.effect) -> bool:
	return _effects_applier_component.is_effect_active(effect)


func apply_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.apply_movement_modificator(modificator)


func remove_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.remove_movement_modificator(modificator)


func disable_collision() -> void:
	_collision_shape.set_deferred("disabled", true)


func enable_collision() -> void:
	_collision_shape.set_deferred("disabled", false)


func _on_effect_added(effect: Enums.effect) -> void:
	print("Effect applied.")
	match effect:
		Enums.effect.GLUED:
			linear_damp = 5
			physics_material_override.bounce = 0.0


func _on_effect_removed(effect: Enums.effect) -> void:
	print("Effect removed.")
	match effect:
		Enums.effect.GLUED:
			linear_damp = _damp_default
			physics_material_override.bounce = 0.4
