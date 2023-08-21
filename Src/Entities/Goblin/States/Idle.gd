extends State

@export var move_state: GoblinMoveState = null
@onready var idle_timer: Timer = $IdleTimer


func _ready() -> void:
	idle_timer.timeout.connect(on_idle_timer_timeout)


func _physics_process(delta: float) -> void:
	move_state.physics_process(delta)


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("idle")
	# Setting to 0.0 so the Goblin is not moving
	move_state.horizontal_speed_scale = 0.0
	idle_timer.start()


func on_exit() -> void:
	idle_timer.stop()
	move_state.horizontal_speed_scale = 1.0


func on_idle_timer_timeout() -> void:
	state_machine.transition_to("Walk")
