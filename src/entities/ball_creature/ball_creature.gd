@tool
class_name BallCreature extends RigidBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Secondary velocity has different effect on RigidBody2D so we should be able to tweak it
const VELOCITY_SECONDARY_SCALE: = 2.0

const FOLLOWING_FORCE: = 150.0

# Creature stops following a player if too near or too far (only in following mode)
const STOP_FOLLOWING_DISTANCE_NEAR: = 4.0
const STOP_FOLLOWING_DISTANCE_FAR: = 120.0

# How fast must the ball move to produce bounce sound effect
const BOUNCE_SFX_VELOCITY: = 20.0

# Wheter to allow leaving happy state íf active; used in title screen
var happy_mode_locked: = true

var attack_strength_buffered: = 0.0
var whistling_player: Player
var following_goal_position: = Vector2.ZERO
var ignore_following: bool = false

var _produce_bounce_sfx: = false
var _damp_default: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
var _bounce_sfx: = preload(SfxResources.BALL_BOUNCE)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _effects_applier_component: EffectsApplierComponent = $EffectsApplierComponent
@onready var _sprite: PalettedSprite = $Node/PalettedSprite
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _ground_detector: RayCast2D = $Node/PalettedSprite/GroundDetector
@onready var _ceiling_detector: RayCast2D = $Node/PalettedSprite/CeilingDetector
@onready var _reaction_symbol: ReactionSymbol = $Node/PalettedSprite/ReactionSymbol
@onready var _following_timer: Timer = $FollowingTimer
@onready var _collision_tester: Area2D = $CollisionTester
@onready var _state_machine: StateMachine = $StateMachine
@onready var _arrow_marker: Sprite2D = $Node/PalettedSprite/ArrowMarker

@export var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable and not freeze

var is_on_floor: bool:
	get:
		return _ground_detector.is_colliding()

var is_on_ceiling: bool:
	get:
		return _ceiling_detector.is_colliding()

var is_inside_wall: bool:
	get: return _collision_tester.has_overlapping_bodies()


var color: int:
	get: return _sprite.color

# Peeking with camera in a level
var enabled_tracking: = false:
	set(value):
		_arrow_marker.enabled = value


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

	if not _ground_detector.is_colliding() and sleeping:
		sleeping = false

	if _effects_applier_component.velocity_secondary != Vector2.ZERO:
		apply_central_force(_effects_applier_component.velocity_secondary * VELOCITY_SECONDARY_SCALE)

	var attack_strength = linear_velocity.length()
	# For a case when the ball is already in other hurtbox
	# so it can make a damage (e.g. standing right next to wooden barrier)
	if attack_strength_buffered != 0.0:
		attack_strength = attack_strength_buffered
		attack_strength_buffered = 0.0

	set_attack_velocity_strength(attack_strength)

	if whistling_player == null or ignore_following:
		return

	var difference: = following_goal_position.x - global_position.x
	var following_direction: = signf(difference)
	var following_goal_distance: = absf(difference)

	# Arrived near whistle position so stop following
	if following_goal_distance <= STOP_FOLLOWING_DISTANCE_NEAR:
		following_goal_position = Vector2.ZERO
		whistling_player = null
		_following_timer.stop()
		return

	apply_force(Vector2.RIGHT * FOLLOWING_FORCE * following_direction)


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


func toggle_collision_layer(value: bool, delay: float = 0.0) -> void:
	delay = maxf(delay, 0.0)
	if delay:
		await get_tree().create_timer(delay).timeout

	set_collision_layer_value(4, value)


func disable_collision() -> void:
	_collision_shape.set_deferred("disabled", true)
	_hitbox_component.toggle_collision(false)
	_ground_detector.enabled = false


func enable_collision() -> void:
	_collision_shape.set_deferred("disabled", false)
	_hitbox_component.toggle_collision(true)
	_ground_detector.enabled = true


func propagate_whistle(source_body: GameCharacter) -> void:
	if not pickable:
		return

	whistling_player = source_body
	following_goal_position = source_body.global_position
	_reaction_symbol.show_symbol(Enums.reaction_symbol.EXCLAMATION)
	_following_timer.start()

	# Creature can get stuck near slope sometimes so we push it up a little to make it move
	if is_on_floor and linear_velocity.is_equal_approx(Vector2.ZERO):
		apply_impulse(Vector2.UP * 90.0)


func _on_effect_added(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			linear_damp = 5
			physics_material_override.bounce = 0.0
			_produce_bounce_sfx = false
		Enums.effect.CRUSHED:
			_state_machine.transition_to("Crushed")


func _on_effect_removed(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			linear_damp = _damp_default
			physics_material_override.bounce = 0.4
			if not _effects_applier_component.is_effect_active(Enums.effect.GLUED):
				_produce_bounce_sfx = true


func _on_body_entered(body: Node) -> void:
	# To avoid producing sound when the ball is spawned
	if not _produce_bounce_sfx:
		_produce_bounce_sfx = true
		return

	if linear_velocity.length() > BOUNCE_SFX_VELOCITY:
		AudioStreamManager2D.play_sound(_bounce_sfx, self)


func _on_following_timer_timeout() -> void:
	whistling_player = null
	_reaction_symbol.show_symbol(Enums.reaction_symbol.QUESTION)
