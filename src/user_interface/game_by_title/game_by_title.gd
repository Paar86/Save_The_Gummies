class_name GameByTitle extends Label


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	show()
	await get_tree().create_timer(3.0).timeout
	Events.change_scene_requested.emit()
