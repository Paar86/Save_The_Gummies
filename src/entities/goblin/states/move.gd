class_name GoblinMoveState extends State

const HORIZONTAL_SPEED_DEFAULT: int = 12
const MAX_FALLING_SPEED: int = 90

@export var character: Goblin = null

var horizontal_speed: int = HORIZONTAL_SPEED_DEFAULT
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 11.0
var horizontal_speed_scale: float = 1.0
var can_attack: bool = true

@onready var can_attack_timer: Timer = $CanAttackTimer


func _ready() -> void:
	assert(character, "Character property cannot be empty!")

	await owner.ready
	direction = character.get_facing_direction()

	character.effect_added.connect(_on_effect_added)
	character.effect_removed.connect(_on_effect_removed)


func physics_process(delta: float) -> void:
	if character.is_on_floor():
		character.velocity_primary.y = 0.0
	else:
		character.velocity_primary.y += gravity * delta

	character.velocity_primary.y = min(character.velocity_primary.y, MAX_FALLING_SPEED)
	character.velocity_primary.x = horizontal_speed * direction * horizontal_speed_scale

	character.velocity = character.velocity_combined
	character.move_and_slide()

	if character.is_on_wall():
		_change_direction()

	if character.player_detector.is_colliding() and can_attack:
		can_attack_timer.stop()
		state_machine.transition_to("ReadyToAttack")


func _change_direction() -> void:
	direction *= -1
	character.change_direction(direction)


func _on_can_attack_timer_timeout() -> void:
	can_attack = true


func _on_effect_added(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			horizontal_speed_scale = 0.5
		Enums.effect.STUNNED:
			state_machine.transition_to("Stunned")
		Enums.effect.WIND:
			_change_direction()


func _on_effect_removed(effect: Enums.effect) -> void:
	match effect:
		Enums.effect.GLUED:
			horizontal_speed_scale = 1.0
