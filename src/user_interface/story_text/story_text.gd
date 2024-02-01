extends Node

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
	_hint_window.show_hint(_story_text)


func _on_hint_window_closed() -> void:
	Events.change_scene_requested.emit()
