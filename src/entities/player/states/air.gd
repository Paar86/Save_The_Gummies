extends State

signal vertical_velocity_changed

const JUMP_FORCE: = 100.0
# Gravity scale when falling down versus jumping up; 1.0 means no change
const JUMP_GRAVITY_SCALE: = 1.0

@export var move_state: PlayerMoveState

# For variable jump hight
@onready var _jump_timer: = $JumpTimer
# For buffering the jump input and transitioning it to next state
@onready var _buffer_timer: = $BufferTimer
# Allow jumping in the air after leaving solid ground
@onready var _coyote_timer: = $CoyoteTimer

var _is_jumping: = false
var _is_jump_buffered: = false
var _allow_coyote_jump: = false
var _jump_sfx: Resource = preload(SfxResources.PLAYER_JUMP)

func on_enter(params: StateParams) -> void:
	Events.player_bounce_up_requested.connect(_on_bounce_up_requested)

	state_machine.change_animation("jump_rise")

	# To make more difficult to steer in the air
	move_state.acceleration_scale = 0.4
	move_state.friction_scale = 0.3

	if params:
		_is_jumping = params.initiated_jumping
		if _is_jumping:
			_apply_upward_force_with_sound()
			move_state.gravity_scale = 0.0
			_jump_timer.start()
		elif params.initial_impulse:
			move_state.character.velocity_primary = params.initial_impulse

	# Procaution if the jump has been initiated by Idle state using buffered jump
	if not Input.is_action_pressed("jump"):
		_is_jumping = false

	if move_state.character.velocity_primary.y > 0.0:
		_allow_coyote_jump = true
		_coyote_timer.start()


func on_exit(transition: Transition) -> void:
	Events.player_bounce_up_requested.disconnect(_on_bounce_up_requested)

	move_state.gravity_scale = 1.0
	move_state.acceleration_scale = 1.0
	move_state.friction_scale = 1.0
	_is_jumping = false
	_is_jump_buffered = false
	_allow_coyote_jump = false
	_jump_timer.stop()
	_buffer_timer.stop()
	_coyote_timer.stop()


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") and move_state .character.touching_ladders.size() > 0:
		state_machine.transition_to("Climb")
		return

	# End of the jump by user input
	if event.is_action_released("jump"):
		_is_jumping = false
		move_state.gravity_scale = 1.0

	if event.is_action_pressed("jump"):
		if _allow_coyote_jump:
			_apply_upward_force_with_sound()
			_allow_coyote_jump = false
			_is_jumping = true
			_jump_timer.start()
			return

		if not _is_jump_buffered:
			_is_jump_buffered = true
			_buffer_timer.start()


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)

	# As long as the player holds the jump button
	if _is_jumping:
		move_state.character.velocity_primary.y = -JUMP_FORCE

	if sign(move_state.character.velocity_primary.y) > 0.0:
			move_state.gravity_scale = JUMP_GRAVITY_SCALE

	if move_state.character.is_on_floor():
		var params: StateParams = null
		if _is_jump_buffered:
			params = StateParams.new()
			params.is_jump_buffered = true
		state_machine.transition_to("Idle", params)
		return

	if move_state.character.is_on_ceiling() and _is_jumping:
		move_state.character.velocity_primary.y = 0.0
		move_state.gravity_scale = JUMP_GRAVITY_SCALE
		_is_jumping = false


func _apply_upward_force_with_sound() -> void:
	AudioStreamManager2D.play_sound(_jump_sfx, move_state.character)
	move_state.character.velocity_primary.y = -JUMP_FORCE


func _on_coyote_timer_timeout() -> void:
	_allow_coyote_jump = false


func _on_buffer_timer_timeout() -> void:
	_is_jump_buffered = false


# When the player reaches maximum jump height
func _on_jump_timer_timeout() -> void:
	_is_jumping = false
	move_state.gravity_scale = 1.0


func _on_bounce_up_requested() -> void:
	move_state.character.velocity_primary.y = -JUMP_FORCE
