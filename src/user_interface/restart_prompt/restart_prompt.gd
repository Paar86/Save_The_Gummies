extends CanvasLayer

const WAIT_TIME_TO_SHOW := 1.7


func _ready() -> void:
	Events.player_dead.connect(_on_player_dead)


func _on_player_dead() -> void:
	await get_tree().create_timer(WAIT_TIME_TO_SHOW).timeout
	visible = true


func _on_restart() -> void:
	Events.reload_level.emit()
	visible = false


func _input(event: InputEvent) -> void:
	if visible and event.is_action_released("jump"):
		_on_restart()
