extends Node

signal half_second_ticked

var _elapsed_time: = 0.0


func _process(delta: float) -> void:
	_elapsed_time += delta

	if _elapsed_time > 0.5:
		half_second_ticked.emit()
		_elapsed_time = 0.0
