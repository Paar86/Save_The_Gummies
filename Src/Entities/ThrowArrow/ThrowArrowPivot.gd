extends Marker2D

const OSCILLATION_DISTANCE: = 2.0
const OSCILLATION_SPEED_MODIFIER: = 15.0
const MIN_ANGLE: = deg_to_rad(-180.0)
const MAX_ANGLE: = deg_to_rad(0.0)
const ROTATION_SPEED: = 3.0
const DEFAULT_ROTATION: = deg_to_rad(65.0)

@onready var throw_arrow_sprite: Sprite2D = $ThrowArrowSprite
var face_direction: = 1.0
var aiming_enabled: = false
var elapsed_time: = 0.0
var orig_horiz_position: = 0.0


func _ready() -> void:
	orig_horiz_position = throw_arrow_sprite.position.x
	Events.player_direction_changed.connect(on_player_direction_changed)


func _process(delta: float) -> void:
	elapsed_time += delta
	throw_arrow_sprite.position.x = orig_horiz_position + sin(elapsed_time * OSCILLATION_SPEED_MODIFIER) * OSCILLATION_DISTANCE

	var rotation_modifier = Input.get_axis("move_left", "move_right")
	rotation += rotation_modifier * ROTATION_SPEED * delta
	rotation = clamp(rotation, MIN_ANGLE, MAX_ANGLE)

	if transform.x.x != 0.0 and sign(transform.x.x) != face_direction:
		Events.player_direction_changed.emit(sign(transform.x.x))


func enable() -> void:
	show()
	aiming_enabled = true
	rotation = get_default_rotation_rad()
	process_mode = Node.PROCESS_MODE_INHERIT


func disable() -> void:
	hide()
	aiming_enabled = false
	rotation = get_default_rotation_rad()
	process_mode = Node.PROCESS_MODE_DISABLED


func get_default_rotation_rad() -> float:
	var rotated_vector = Vector2.UP.rotated(DEFAULT_ROTATION * face_direction)
	return Vector2.RIGHT.angle_to(rotated_vector)


func on_player_direction_changed(new_direction: float) -> void:
	face_direction = new_direction
	if not aiming_enabled:
		rotation = get_default_rotation_rad()
