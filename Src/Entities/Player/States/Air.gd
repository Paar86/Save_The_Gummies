extends State

const JUMP_FORCE: = 100.0
const JUMP_GRAVITY_SCALE: = 1.4

@export var move_state: PlayerMoveState

# For variable jump hight
@onready var jump_timer: = $JumpTimer
# For buffering the jump input and transitioning it to next state
@onready var buffer_timer: = $BufferTimer
# Allow jumping in the air after leaving solid ground
@onready var coyote_timer: = $CoyoteTimer

var is_jumping: = false
var is_jump_buffered: = false
var allow_coyote_jump: = false


func on_enter(params: StateParams) -> void:
	# To make more difficult to steer in the air
	move_state.acceleration_scale = 0.4
	move_state.friction_scale = 0.3

	if params:
		is_jumping = params.initiated_jumping
		if is_jumping:
			move_state.character.velocity.y = -JUMP_FORCE
			move_state.gravity_scale = 0.0
			jump_timer.start()

	# Procaution if the jump has been initiated by Idle state using buffered jump
	if not Input.is_action_pressed("jump"):
		is_jumping = false

	if move_state.character.velocity.y > 0.0:
		allow_coyote_jump = true
		coyote_timer.start()


func on_exit() -> void:
	move_state.gravity_scale = 1.0
	move_state.acceleration_scale = 1.0
	move_state.friction_scale = 1.0
	is_jumping = false
	is_jump_buffered = false
	jump_timer.stop()
	buffer_timer.stop()
	coyote_timer.stop()


func unhandled_input(event: InputEvent) -> void:
	# End of the jump by user input
	if event.is_action_released("jump"):
		is_jumping = false
		move_state.gravity_scale = 1.0

	if event.is_action_pressed("jump"):
		if allow_coyote_jump:
			move_state.character.velocity.y = -JUMP_FORCE
			allow_coyote_jump = false
			is_jumping = true
			jump_timer.start()
			return

		if not is_jump_buffered:
			is_jump_buffered = true
			buffer_timer.start()


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)

	# As long as the player holds the jump button
	if is_jumping:
		move_state.character.velocity.y = -JUMP_FORCE

	if sign(move_state.character.velocity.y) > 0.0:
			move_state.gravity_scale = JUMP_GRAVITY_SCALE

	if move_state.character.is_on_floor():
		var params: StateParams = null
		if is_jump_buffered:
			params = StateParams.new()
			params.is_jump_buffered = true
		state_machine.transition_to("Idle", params)
		return

	if move_state.character.is_on_ceiling():
		move_state.character.velocity.y = 0.0
		move_state.gravity_scale = JUMP_GRAVITY_SCALE
		is_jumping = false


func _on_coyote_timer_timeout() -> void:
	allow_coyote_jump = false


func _on_buffer_timer_timeout() -> void:
	is_jump_buffered = false


# When the player reaches maximum jump height
func _on_jump_timer_timeout() -> void:
	is_jumping = false
	move_state.gravity_scale = 1.0
