class_name GoblinMoveState extends State


const HORIZONTAL_SPEED_DEFAULT: int = 12
const MAX_FALLING_SPEED: int = 90

@export var character: Goblin = null
@onready var can_attack_timer: Timer = $CanAttackTimer

var horizontal_speed: int = HORIZONTAL_SPEED_DEFAULT
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 11.0
var horizontal_speed_scale: float = 1.0
var can_attack: bool = true


func _ready() -> void:
	assert(character, "Character property cannot be empty!")

	await owner.ready
	direction = character.get_facing_direction()

	character.effect_added.connect(on_effect_added)
	character.effect_removed.connect(on_effect_removed)


func physics_process(delta: float) -> void:
	if character.is_on_floor():
		character.velocity.y = 0.0
	else:
		character.velocity.y += gravity * delta

	character.velocity.y = min(character.velocity.y, MAX_FALLING_SPEED)
	character.velocity.x = horizontal_speed * direction * horizontal_speed_scale

	character.move_and_slide()

	if character.is_on_wall():
		direction *= -1
		character.change_direction(direction)

	if character.player_detector.is_colliding() and can_attack:
		can_attack_timer.stop()
		state_machine.transition_to("ReadyToAttack")


func propagate_effects(effects: Array[String]) -> void:
	if effects.has("stun"):
		state_machine.transition_to("Stunned")


func on_can_attack_timer_timeout() -> void:
	can_attack = true


func on_effect_added(effect: Enums.effects) -> void:
	match effect:
		Enums.effects.GLUED:
			horizontal_speed_scale = 0.5


func on_effect_removed(effect: Enums.effects) -> void:
	match effect:
		Enums.effects.GLUED:
			horizontal_speed_scale = 1.0
