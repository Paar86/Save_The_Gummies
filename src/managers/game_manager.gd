extends Node

@export var title_screen: PackedScene
@export var levels: Array[PackedScene]
@export var credits: PackedScene

@onready var _active_scene: Node = $ActiveScene

var _current_scene: Node
var _restart_scene: Node
var _current_scene_index: int = 0
var _game_stats: GameStats


func _ready() -> void:
	_game_stats = GameStats.new()

	Events.change_level_requested.connect(_on_change_level_requested)
	Events.reload_level_requested.connect(_on_reload_level_requested)

	_current_scene = title_screen.instantiate()
	_active_scene.add_child(_current_scene)
	_current_scene_index = 0


func get_level_instance(index: int) -> Level:
	index = clamp(index, 0, levels.size() - 1)
	var level_instance = levels[_current_scene_index - 1].instantiate() as Level
	level_instance.game_stats = _game_stats
	level_instance.start_with_peek_animation = true
	return level_instance


func _on_change_level_requested() -> void:
	get_tree().paused = true
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


func _on_reload_level_requested() -> void:
	_current_scene.queue_free()

	if _current_scene_index == 0:
		_current_scene = title_screen.instantiate()
	elif _current_scene_index > levels.size():
		_current_scene = credits.instantiate()
	else:
		_current_scene = levels[_current_scene_index - 1].instantiate()

	_active_scene.add_child(_current_scene)
