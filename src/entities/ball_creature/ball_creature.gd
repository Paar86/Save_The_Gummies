@tool
class_name BallCreature extends RigidBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Secondary velocity has different effect on RigidBody2D so we should be able to tweak it
const VELOCITY_SECONDARY_SCALE: = 2.0
enum colors {
	BLUE_DARK_BLUE,
	GREEN_DARK_GREEN,
	YELLOW_DARK_YELLOW,
	MAGENTA_MAROON,
	PINK_MAROON,
	DARK_YELLOW_BROWN,
	WHEAT_YELLOW_BROWN
}

@export var color = colors.BLUE_DARK_BLUE : set = _set_color;

var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable

var attack_strength_buffered: = 0.0
var _damp_default: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _effects_applier_component: EffectsApplierComponent = $EffectsApplierComponent
@onready var _sprite: Sprite2D = $Node/Sprite2D
@onready var _hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_effects_applier_component.effect_added.connect(func(effect: Enums.effect) -> void: effect_added.emit(effect))
	_effects_applier_component.effect_removed.connect(func(effect: Enums.effect) -> void: effect_removed.emit(effect))

	effect_added.connect(_on_effect_added)
	effect_removed.connect(_on_effect_removed)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if _effects_applier_component.velocity_secondary != Vector2.ZERO:
		apply_central_force(_effects_applier_component.velocity_secondary * VELOCITY_SECONDARY_SCALE)

	var attack_strength = linear_velocity.length()
	# For a case when the ball is already in other hurtbox
	# so it can make a damage (e.g. standing right next to wooden barrier)
	if attack_strength_buffered != 0.0:
		attack_strength = attack_strength_buffered
		attack_strength_buffered = 0.0

	set_attack_velocity_strength(attack_strength)


func apply_effect(effect: Enums.effect) -> void:
	_effects_applier_component.apply_effect(effect)


func remove_effect(effect: Enums.effect) -> void:
	_effects_applier_component.remove_effect(effect)


func set_attack_velocity_strength(strength: float) -> void:
	_hitbox_component.attack_velocity_strength = strength


func is_effect_active(effect: Enums.effect) -> bool:
	return _effects_applier_component.is_effect_active(effect)


func apply_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.apply_movement_modificator(modificator)


func remove_movement_modificator(modificator: Vector2) -> void:
	_effects_applier_component.remove_movement_modificator(modificator)


func disable_collision() -> void:
	_collision_shape.set_deferred("disabled", true)
	_hitbox_component.toggle_collision(false)


func enable_collision() -> void:
	_collision_shape.set_deferred("disabled", false)
	_hitbox_component.toggle_collision(true)


func _on_effect_added(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			linear_damp = 5
			physics_material_override.bounce = 0.0


func _on_effect_removed(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			linear_damp = _damp_default
			physics_material_override.bounce = 0.4


func _set_color(new_color : colors):
	_sprite.get_material().set_shader_parameter("palette", new_color)
	color = new_color
