extends Marker2D

const OSCILLATION_DISTANCE: = 2.0
const OSCILLATION_SPEED_MODIFIER: = 15.0
const MIN_ANGLE: = deg_to_rad(-200.0)
const MAX_ANGLE: = deg_to_rad(20.0)
const ROTATION_SPEED: = 3.0
const DEFAULT_ROTATION: = deg_to_rad(65.0)
const INITIAL_DOT_OFFSET: = 7.0
const DOT_GAP: = 3.5

var _face_direction: = 1.0
var _aiming_enabled: = false

@onready var _throw_sprite: Sprite2D = $SpriteContainer/ThrowArrowSprite
@onready var _dots: Array = $DotsContainer.get_children()


func _ready() -> void:
#	orig_horiz_position = throw_arrow_sprite.position.x
	Events.player_direction_changed.connect(on_player_direction_changed)


func _process(delta: float) -> void:
#	elapsed_time += delta
#	throw_arrow_sprite.position.x = orig_horiz_position + sin(elapsed_time * OSCILLATION_SPEED_MODIFIER) * OSCILLATION_DISTANCE

	var rotation_modifier = Input.get_axis("move_left", "move_right")
	rotation += rotation_modifier * ROTATION_SPEED * delta
	rotation = clamp(rotation, MIN_ANGLE, MAX_ANGLE)

	if transform.x.x != 0.0 and sign(transform.x.x) != _face_direction:
		Events.player_direction_changed.emit(sign(transform.x.x))

	_place_dots()


func _place_dots():
	var dots_offset: = INITIAL_DOT_OFFSET
	var direction: = (_throw_sprite.global_position - global_position).normalized()
	for dot in _dots:
		dot.global_position = global_position + dots_offset*direction
		dots_offset += DOT_GAP


func enable() -> void:
	_throw_sprite.show()
	_place_dots()
	for dot in _dots:
		dot.show()
	_aiming_enabled = true
	rotation = get_default_rotation_rad()
	process_mode = Node.PROCESS_MODE_INHERIT


func disable() -> void:
	_throw_sprite.hide()
	for dot in _dots:
		dot.hide()
	_aiming_enabled = false
	rotation = get_default_rotation_rad()
	process_mode = Node.PROCESS_MODE_DISABLED


func get_default_rotation_rad() -> float:
	var rotated_vector = Vector2.UP.rotated(DEFAULT_ROTATION * _face_direction)
	return Vector2.RIGHT.angle_to(rotated_vector)


func on_player_direction_changed(new_direction: float) -> void:
	_face_direction = new_direction
	if not _aiming_enabled:
		rotation = get_default_rotation_rad()
