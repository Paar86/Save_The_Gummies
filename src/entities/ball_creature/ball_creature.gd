@tool
class_name BallCreature extends RigidBody2D

signal effect_added(effect: Enums.effect)
signal effect_removed(effect: Enums.effect)

# Secondary velocity has different effect on RigidBody2D so we should be able to tweak it
const VELOCITY_SECONDARY_SCALE: = 2.0

const FOLLOWING_FORCE: = 150.0

# Creature stops following a player if too near or too far (only in following mode)
const STOP_FOLLOWING_DISTANCE_NEAR: = 8.0
const STOP_FOLLOWING_DISTANCE_FAR: = 120.0

enum colors {
	BLUE_DARK_BLUE,
	GREEN_DARK_GREEN,
	YELLOW_DARK_YELLOW,
	MAGENTA_MAROON,
	PINK_MAROON,
	DARK_YELLOW_BROWN,
	WHEAT_YELLOW_BROWN
}

@export var color: = colors.BLUE_DARK_BLUE : set = _set_color;

var start_in_safe_state: = false
var attack_strength_buffered: = 0.0
var whistling_player: Player
var ignore_following: bool = false

var _produce_bounce_sfx: = false
var _damp_default: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
var _bounce_sfx: = preload(SfxResources.BALL_BOUNCE)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _effects_applier_component: EffectsApplierComponent = $EffectsApplierComponent
@onready var _sprite: Sprite2D = $Node/Sprite2D
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _ground_detector: RayCast2D = $Node/Sprite2D/GroundDetector
@onready var _reaction_symbol: ReactionSymbol = $Node/Sprite2D/ReactionSymbol
@onready var _following_timer: Timer = $FollowingTimer
@onready var _collision_tester: Area2D = $CollisionTester
@onready var _state_machine: StateMachine = $StateMachine

var pickable: bool = true:
	set(value):
		pickable = value
	get:
		return pickable

var is_on_floor: bool:
	get:
		return _ground_detector.is_colliding()

var is_inside_wall: bool:
	get: return _collision_tester.has_overlapping_bodies()

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if start_in_safe_state:
		_state_machine.initial_state = get_node("StateMachine/Safe")
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

	if whistling_player == null or ignore_following:
		return

	var to_player_vector = whistling_player.global_position - global_position
	var player_distance = to_player_vector.length()

	# Arrived near player's position so stop following
	if player_distance <= STOP_FOLLOWING_DISTANCE_NEAR or player_distance >= STOP_FOLLOWING_DISTANCE_FAR:
		whistling_player = null
		_following_timer.stop()
		return

	var following_direction = sign(to_player_vector.x)
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


func disable_collision() -> void:
	_collision_shape.set_deferred("disabled", true)
	_hitbox_component.toggle_collision(false)


func enable_collision() -> void:
	_collision_shape.set_deferred("disabled", false)
	_hitbox_component.toggle_collision(true)


func propagate_whistle(source_body: GameCharacter) -> void:
	if not pickable:
		return

	whistling_player = source_body
	_reaction_symbol.show_symbol(Enums.reaction_symbol.EXCLAMATION)
	_following_timer.start()

	# Creature can get stuck near slope sometimes so we push it up a little to make it move
	if is_on_floor and !linear_velocity.length():
		apply_impulse(Vector2.UP * 60.0)


func _on_effect_added(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			linear_damp = 5
			physics_material_override.bounce = 0.0
			_produce_bounce_sfx = false


func _on_effect_removed(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			linear_damp = _damp_default
			physics_material_override.bounce = 0.4
			if not _effects_applier_component.is_effect_active(Enums.effect.GLUED):
				_produce_bounce_sfx = true


func _set_color(new_color : colors):
	get_node("Node/Sprite2D").get_material().set_shader_parameter("palette", new_color)
	color = new_color


func _on_body_entered(body: Node) -> void:
	if not _produce_bounce_sfx:
		_produce_bounce_sfx = true
		return

	AudioStreamManager2D.play_sound(_bounce_sfx, self)


func _on_following_timer_timeout() -> void:
	whistling_player = null
	_reaction_symbol.show_symbol(Enums.reaction_symbol.QUESTION)
