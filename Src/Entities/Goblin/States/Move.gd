class_name GoblinMoveState extends State


const HORIZONTAL_SPEED_DEFUALT: int = 8
const MAX_FALLING_SPEED: int = 90

@export var character: Goblin = null
var horizontal_speed: int = HORIZONTAL_SPEED_DEFUALT
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 11.0
var horizontal_speed_scale: float = 1.0


func _ready() -> void:
	assert(character, "Character property cannot be empty!")

	await owner.ready
	direction = character.get_facing_direction()


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
