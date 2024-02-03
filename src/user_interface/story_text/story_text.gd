class_name StoryText extends Node

var _story_text: = "Evil goblins
attacked your
farm and stole
your Gummies.
Find them all
and bring them
home!"

@onready var _hint_window: HintWindow = $HintWindow


func _ready() -> void:
	_hint_window.hint_window_closed.connect(_on_hint_window_closed)

	await get_tree().create_timer(1.0).timeout
	_hint_window.show_hint(_story_text)


func _on_hint_window_closed() -> void:
	await get_tree().create_timer(2.0).timeout
	Events.change_scene_requested.emit()
