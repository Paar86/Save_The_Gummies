class_name Level extends Node

signal camera_above_player

@export var start_with_peek_animation: bool = false

var ball_creature: BallCreature
var _checkpoints: Array[Checkpoint] = []
# For remembering the position of Player in tree for proper z-indexing
var _player_tree_index: = 0
var _player_respawn_point: = Vector2.ZERO
var _player_scene: PackedScene = preload("res://src/entities/player/player.tscn")
var _creature_packed: PackedScene = preload("res://src/entities/ball_creature/ball_creature_captured.tscn")
var _game_stats: GameStats

@onready var _player: Player = $Player
@onready var _player_camera: Camera2D = $PlayerCamera
@onready var _peek_camera: PeekCamera = $PeekCamera
@onready var _tile_map: TileMap = $TileMap
@onready var _health_ui: TextureRect = $UI/HealthCounter
@onready var _player_respawn_timer: Timer = $PlayerRespawnTimer
@onready var _ball_creatures_captured_folder: Node = $ObjectsBehind/BallCreaturesCaptured
@onready var _initial_peek_delay_timer: Timer = $InitialPeekDelayTimer
@onready var _pause_screen: CanvasLayer = $PauseScreen
@onready var _hint_window: HintWindow = $UI/HintWindow
@onready var _transition_layer: TransitionLayer = $TransitionLayer

var game_stats: GameStats:
	set(value): _game_stats = value


func _ready() -> void:
	var ball_creature_scenes = find_children("*", "BallCreature")
	assert(ball_creature_scenes.size() > 0, "There is no ball create scene child!")
	ball_creature = ball_creature_scenes[0]
	ball_creature.enabled_tracking = true

	assert(_player, "No player in the level!")

	_player_respawn_point = _player.global_position
	_player_tree_index = _player.get_index()

	Events.pause_level_requested.connect(_on_pause_level_requested)
	Events.unpause_level_requested.connect(_on_unpause_level_requested)

	_configure_hints()
	_configure_player()
	_configure_basket()
	_configure_cameras()
	_register_checkpoints()

	get_tree().paused = true
	_transition_layer.start_transition_effect(0.0, 1.0)
	await _transition_layer.transition_finished
	get_tree().paused = false

	if start_with_peek_animation:
		get_tree().paused = true
		_pause_screen.set_process_input(false)
		_peek_camera.set_process_unhandled_input(false)
		await _play_peek_animation()
		get_tree().paused = false
		_pause_screen.set_process_input(true)
		_peek_camera.set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_peek_camera.make_current()


func _configure_basket() -> void:
	var basket_scene: Basket = find_child("Basket")
	if not basket_scene:
		push_error("No basket in the level!")
		return

	basket_scene.ball_creature_captured.connect(_on_ball_creature_captured)

	# Spawn already captured ball creatures
	if _game_stats:
		var spawn_points_dict: = basket_scene.get_creatures_spawn_points(_game_stats.saved_ball_creatures_colors)
		for global_pos_key in spawn_points_dict:
			var creature_instance: = _creature_packed.instantiate() as BallCreatureCaptured
			creature_instance.animation_delay = randf()
			creature_instance.color = spawn_points_dict[global_pos_key]
			creature_instance.global_position = global_pos_key
			_ball_creatures_captured_folder.add_child(creature_instance)
			creature_instance.owner = self


func _configure_cameras() -> void:
	# Setting camera limits
	var tile_map_boundaries: = _tile_map.get_used_rect()
	var tile_map_cell_size: = _tile_map.rendering_quadrant_size

	for camera in [_player_camera, _peek_camera]:
		camera.limit_left = tile_map_boundaries.position.x * tile_map_cell_size + 5
		camera.limit_right = tile_map_boundaries.end.x * tile_map_cell_size - 5
		camera.limit_top = tile_map_boundaries.position.y * tile_map_cell_size + 5
		camera.limit_bottom = tile_map_boundaries.end.y * tile_map_cell_size - 5

	# Additional settings
	_peek_camera.ball_creature = ball_creature
	_peek_camera.arrived_at_player_camera.connect(_on_peek_camera_at_player)


func _register_checkpoints() -> void:
	_checkpoints.assign(find_children("*", "Checkpoint"))
	_checkpoints.sort_custom(func(ch1, ch2): return ch2.name.nocasecmp_to(ch1.name) > 0)

	for checkpoint in _checkpoints:
		checkpoint.checkpoint_activated.connect(_on_checkpoint_activated)


func _configure_player() -> void:
	var camera_transform_scene: = RemoteTransform2D.new()
	camera_transform_scene.name = "CameraTransform"
	camera_transform_scene.remote_path = _player_camera.get_path()
	_player.add_child(camera_transform_scene)
	camera_transform_scene.owner = self

	# Signals
	_player.lives_depleted.connect(_on_player_lives_depleted)


func _configure_hints() -> void:
	var hint_signposts: Array[HintSignpost]
	hint_signposts.assign(find_children("*", "HintSignpost"))
	if hint_signposts.size() == 0:
		return

	for signpost in hint_signposts:
		signpost.hint_message_requested.connect(_on_hint_message_requested)

	_hint_window.hint_window_closed.connect(_on_hint_window_closed)


func _play_peek_animation() -> void:
	_peek_camera.make_current()
	await _create_peek_delay()
	_peek_camera.set_ball_creature_as_target()
	await _peek_camera.arrived_at_target
	await _create_peek_delay()
	_peek_camera.set_player_camera_as_target()
	await _peek_camera.arrived_at_target
	await _create_peek_delay()
	_player_camera.make_current()


func _create_peek_delay() -> void:
	_initial_peek_delay_timer.start()
	await _initial_peek_delay_timer.timeout


func _on_peek_camera_at_player() -> void:
	_player_camera.make_current()


func _on_checkpoint_activated(activated_checkpoint: Checkpoint) -> void:
	var activated_checkpoint_index = _checkpoints.find(activated_checkpoint)
	if activated_checkpoint_index == -1:
		push_error("Activated checkpoint is not part of current level!")
		return

	# Deactivate all previous checkpoints if player somehow missed them
	for i in activated_checkpoint_index:
		_checkpoints[i].set_deferred("monitoring", false)

	# And remember the new respawn position
	_player_respawn_point = activated_checkpoint.global_position


func _on_player_lives_depleted() -> void:
	_player_respawn_timer.start()

	if _game_stats:
		_game_stats.player_deaths_number += 1


func _on_player_respawn_timer_timeout() -> void:
	var player = _player_scene.instantiate() as Player
	player.global_position = _player_respawn_point
	player.start_invincible = true
	player.name = "Player"
	_player = player
	call_deferred("add_child", player)
	call_deferred("move_child", player, _player_tree_index)

	await player.ready
	player.owner = self
	_configure_player()


func _on_ball_creature_captured(ball_creature: BallCreature) -> void:
	if _game_stats:
			_game_stats.saved_ball_creatures_colors.append(ball_creature.color)

	get_tree().paused = true
	_transition_layer.start_transition_effect(1.0, 0.0, false)
	await _transition_layer.transition_finished
	Events.change_level_requested.emit()


func _on_pause_level_requested() -> void:
	get_tree().paused = true
	_pause_screen.show()


func _on_unpause_level_requested() -> void:
	get_tree().paused = false
	_pause_screen.hide()


func _on_hint_message_requested(message: String) -> void:
	get_tree().paused = true
	_hint_window.show_hint(message)


func _on_hint_window_closed() -> void:
	get_tree().paused = false
