extends State

@onready var kick_timer: Timer = $Timer


func _ready() -> void:
	kick_timer.timeout.connect(on_kick_timeout)


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("kick")
	kick_timer.start()


func on_kick_timeout() -> void:
	state_machine.transition_to("Idle")
