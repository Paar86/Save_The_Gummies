class_name ReactionSymbol extends Sprite2D

@onready var _show_timer: Timer = $ShowTimer


func show_symbol(frame_index: Enums.reaction_symbol) -> void:
	frame_index = mini(frame_index, hframes - 1)

	frame = frame_index
	show()
	_show_timer.start()


func force_stop() -> void:
	_show_timer.stop()
	hide()


func _on_show_timer_timeout() -> void:
	hide()
