extends Marker2D

@onready var sprite: Sprite2D = $ThrowArrow

const OSCILLATION_DISTANCE: = 2.0
const OSCILLATION_SPEED_MODIFIER: = 15.0
const ARROW_ROTATION_SPEED: = 3.0

# Angle limit for throw arrow when facing left or right
const LOWEST_ANGLE_LIMIT_RIGHT: = deg_to_rad(-90.0)
const HIGHEST_ANGLE_LIMIT_RIGHT: = deg_to_rad(0.0)
const LOWEST_ANGLE_LIMIT_LEFT: = LOWEST_ANGLE_LIMIT_RIGHT - deg_to_rad(90.0)
const HIGHEST_ANGLE_LIMIT_LEFT: = HIGHEST_ANGLE_LIMIT_RIGHT - deg_to_rad(90.0)

var elapsed_time: = 0.0
var facing_direction: = 1.0
var orig_horiz_position: = 0.0
var lowest_angle_limit: = LOWEST_ANGLE_LIMIT_RIGHT
var highest_angle_limit: = HIGHEST_ANGLE_LIMIT_RIGHT


func _ready() -> void:
	orig_horiz_position = sprite.position.x


func _process(delta: float) -> void:
	elapsed_time += delta
	sprite.position.x = orig_horiz_position + sin(elapsed_time * OSCILLATION_SPEED_MODIFIER) * OSCILLATION_DISTANCE

	# Rotation direction should be reversed when facing left
	var rotation_direction = Input.get_axis("move_up", "move_down") * facing_direction
	if rotation_direction:
		rotate(ARROW_ROTATION_SPEED * delta * rotation_direction)
		rotation = clamp(rotation, lowest_angle_limit, highest_angle_limit)


func disable() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func enable() -> void:
	show()
	reset_angle()
	process_mode = Node.PROCESS_MODE_INHERIT


func change_direction(new_direction: float) -> void:
	match new_direction:
		-1.0:
			lowest_angle_limit = LOWEST_ANGLE_LIMIT_LEFT
			highest_angle_limit = HIGHEST_ANGLE_LIMIT_LEFT
		1.0:
			lowest_angle_limit = LOWEST_ANGLE_LIMIT_RIGHT
			highest_angle_limit = HIGHEST_ANGLE_LIMIT_RIGHT

	facing_direction = new_direction
	reset_angle()


# Varies with facing left or right
func get_default_angle() -> float:
	var angle_difference = abs(lowest_angle_limit) - abs(highest_angle_limit)
	return highest_angle_limit - angle_difference / 2


func reset_angle() -> void:
	rotation = get_default_angle()
