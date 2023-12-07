extends CanvasLayer

var _pause = true


func _ready() -> void:
	Events.reload_level.connect(_on_reload)
	Events.player_dead.connect(_on_player_dead)


func _on_continue_button_up() -> void:
	Events.pause_level.emit()


func _input(event: InputEvent) -> void:
	if _pause and event.is_action_pressed("pause"):
		Events.pause_level.emit()


func _on_reload() -> void:
	_pause = true


func _on_player_dead() -> void:
	_pause = false
