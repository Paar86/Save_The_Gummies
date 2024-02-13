extends Node

@export var author_title: PackedScene
@export var title_screen: PackedScene
@export var main_menu_screen: PackedScene
@export var levels: Array[PackedScene]
@export var credits: PackedScene
@export var story_text: PackedScene

@onready var _active_scene: Node = $ActiveScene

var _current_scene: Node
var _restart_scene: Node
var _current_level_index: int = 0
var _game_stats: GameStats


func _ready() -> void:
	Events.change_scene_requested.connect(_on_change_scene_requested)
	Events.new_game_requested.connect(_on_new_game_requested)
	Events.change_level_requested.connect(_on_change_level_requested)
	Events.reload_level_requested.connect(_on_reload_level_requested)

	_current_scene = author_title.instantiate()
	_active_scene.add_child(_current_scene)
	_current_level_index = 0


func _load_scene(requested_scene: Node) -> void:
	if not requested_scene:
		return

	_current_scene.queue_free()
	await _current_scene.tree_exited

	_active_scene.add_child(requested_scene)
	_current_scene = requested_scene
	requested_scene.owner = self


func _load_level(index: int) -> void:
	index = clampi(index, 0, levels.size() - 1)
	_current_level_index = index

	var level_instance: = levels[index].instantiate() as Level
	level_instance.game_stats = _game_stats
	level_instance.animate_at_level_start = true
	level_instance.level_number = index + 1
	_load_scene(level_instance)


func _on_change_level_requested() -> void:
	if not _current_scene is Level:
		return

	if _current_level_index < levels.size() - 1:
		_load_level(_current_level_index + 1)
		return

	# TODO: Otherwise load credits scene.


func _on_reload_level_requested() -> void:
	if not _current_scene is Level:
		return

	_load_level(_current_level_index)


func _on_new_game_requested(initial_level_number: int) -> void:
	_game_stats = GameStats.new()
	_game_stats.initial_level_number = initial_level_number

	_load_scene(story_text.instantiate())


func _on_change_scene_requested() -> void:
	if _current_scene is GameByTitle:
		_load_scene(title_screen.instantiate())

	if _current_scene is TitleScreen:
		var scene: = main_menu_screen.instantiate()
		(scene as MainMenuScreen).level_count = levels.size()
		_load_scene(scene)

	if _current_scene is StoryText:
		var start_level_index: = _game_stats.initial_level_number - 1
		_load_level(start_level_index)

