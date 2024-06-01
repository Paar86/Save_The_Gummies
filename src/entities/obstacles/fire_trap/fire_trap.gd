extends Node2D

enum FireState { DELAYED, INACTIVE, TELEGRAPHING, ACTIVE }

@export var delay_half_ticks: = 0
@export var inactive_half_ticks: = 6
@export var telegraph_half_ticks: = 4
@export var active_half_ticks: = 4

var _current_state: FireState = FireState.DELAYED
var _half_ticks_counter: = 0
var _target_ticks_count: = -1
var _count_half_ticks: = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var _fire_tele_sound: AudioStreamPlayer2D = $FireTelegraphSound
@onready var _fire_sound: AudioStreamPlayer2D = $FireSound


func _ready() -> void:
	GlobalTicker.half_second_ticked.connect(_on_half_second_ticked)
	_target_ticks_count = delay_half_ticks


func _process(delta: float) -> void:
	if _target_ticks_count == -1:
		#push_error("Target ticks count not set properly!")
		set_process(false)
		return

	if _half_ticks_counter < _target_ticks_count:
		return

	_half_ticks_counter = 0
	_target_ticks_count = -1
	_transition_to_another_state()


func toggle_collision(value: bool) -> void:
	_hitbox_collision.set_deferred("disabled", !value)


func _on_half_second_ticked() -> void:
	# For grouping fire traps under a single node which can be disable,
	# e.g. with VisibilityEnabler2D
	if not get_parent().process_mode == PROCESS_MODE_INHERIT:
		return

	_half_ticks_counter += 1


func _transition_to_another_state() -> void:
	_fire_tele_sound.stop()
	_fire_sound.stop()

	match _current_state:
		FireState.DELAYED, FireState.INACTIVE:
			_current_state = FireState.TELEGRAPHING
			_fire_tele_sound.play()
			_animated_sprite.play("telegraph")
			_target_ticks_count = telegraph_half_ticks
		FireState.TELEGRAPHING:
			_current_state = FireState.ACTIVE
			_fire_sound.play()
			_animated_sprite.play("active")
			toggle_collision(true)
			_target_ticks_count = active_half_ticks
		FireState.ACTIVE:
			_current_state = FireState.INACTIVE
			_animated_sprite.play("inactive")
			toggle_collision(false)
			_target_ticks_count = inactive_half_ticks
