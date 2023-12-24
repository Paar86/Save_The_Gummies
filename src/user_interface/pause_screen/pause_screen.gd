extends CanvasLayer

var _can_pause = true


func _ready() -> void:
	Events.reload_level_requested.connect(_on_reload)


func _on_continue_button_up() -> void:
	Events.unpause_level_requested.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not visible and _can_pause:
			Events.pause_level_requested.emit()
			return

		if visible:
			Events.unpause_level_requested.emit()


func _on_reload() -> void:
	_can_pause = true
