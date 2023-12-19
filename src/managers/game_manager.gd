extends Node

@export var title_screen: PackedScene
@export var levels: Array[PackedScene]
@export var credits: PackedScene
@export var pause_screen: PackedScene

@onready var _active_scene: Node = $ActiveScene

var _current_scene: Node
var _pause_scene: Node
var _restart_scene: Node
var _current_scene_index: int = 0
var _game_stats: GameStats


func _ready() -> void:
	_game_stats = GameStats.new()

	Events.change_level_requested.connect(_on_change_level)
	Events.reload_level_requested.connect(_on_reload_level)
	Events.pause_level_requested.connect(_on_pause_level)

	_current_scene = title_screen.instantiate()
	_active_scene.add_child(_current_scene)
	_current_scene_index = 0

	_pause_scene = pause_screen.instantiate()
	self.add_child(_pause_scene)
	_pause_scene.visible = false


func get_level_instance(index: int) -> Level:
	index = clamp(index, 0, levels.size() - 1)
	var level_instance = levels[_current_scene_index - 1].instantiate()
	level_instance.game_stats = _game_stats
	return level_instance


func _on_change_level() -> void:
	_current_scene.queue_free()

	_current_scene_index += 1
	if _current_scene_index > levels.size() + 1:
		_current_scene = title_screen.instantiate()
		_current_scene_index = 0
	elif _current_scene_index > levels.size():
		_current_scene = credits.instantiate()
	else:
		_current_scene = get_level_instance(_current_scene_index)

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


func _on_pause_level() -> void:
	# Dont pause on title screen and credits
	if not (_current_scene_index in range(1, levels.size() + 1)):
		return

	get_tree().paused = !get_tree().paused
	_pause_scene.visible = !_pause_scene.visible
