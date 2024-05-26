class_name GameByTitle extends Label

@onready var _greeting_sfx: = preload(SfxResources.GREETING)

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	show()
	AudioStreamManager.play_sound(_greeting_sfx)
	await get_tree().create_timer(3.0).timeout
	Events.change_scene_requested.emit()
