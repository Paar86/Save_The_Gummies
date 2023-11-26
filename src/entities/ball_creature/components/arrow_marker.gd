extends Sprite2D

const AMPLITUDE: = 4.0
const FREQUENCY: = 0.01
const INITIAL_POSITION: = 12.0


func _physics_process(delta: float) -> void:
	if not self.visible:
		return

	position.y = AMPLITUDE * sin(Time.get_ticks_msec() * FREQUENCY) - INITIAL_POSITION


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		self.visible = true
	if event.is_action_released("ui_accept"):
		self.visible = false
