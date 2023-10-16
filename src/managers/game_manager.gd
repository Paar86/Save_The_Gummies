extends Node

@export var title_screen: PackedScene
@export var levels: Array[PackedScene]
@export var credits: PackedScene

@onready var _active_scene: Node = $ActiveScene

var _current_scene: Node
var _current_scene_index: int = 0


func _ready() -> void:
	Events.change_level.connect(_on_change_level)
	Events.reload_level.connect(_on_reload_level)

	_current_scene = title_screen.instantiate()
	_active_scene.add_child(_current_scene)
	_current_scene_index = 0


func _on_change_level() -> void:
	_current_scene.queue_free()

	_current_scene_index += 1
	if _current_scene_index > levels.size() + 1:
		_current_scene = title_screen.instantiate()
		_current_scene_index = 0
	elif _current_scene_index > levels.size():
		_current_scene = credits.instantiate()
	else:
		_current_scene = levels[_current_scene_index - 1].instantiate()

	_active_scene.add_child(_current_scene)


func _on_reload_level() -> void:
	_current_scene.queue_free()

	if _current_scene_index == 0:
		_current_scene = title_screen.instantiate()
	elif _current_scene_index > levels.size():
		_current_scene = credits.instantiate()
	else:
		_current_scene = levels[_current_scene_index - 1].instantiate()

	_active_scene.add_child(_current_scene)

