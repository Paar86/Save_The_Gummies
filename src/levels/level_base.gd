class_name Level extends Node

signal camera_above_player

var ball_creature: BallCreature
var _checkpoints: Array[Checkpoint] = []
# For remembering the position of Player in tree for proper z-indexing
var _player_tree_index: = 0
var _player_respawn_point: = Vector2.ZERO
var _player_scene: PackedScene = preload("res://src/entities/player/player.tscn")
var _game_stats: GameStats

@onready var _player: Player = $Player
@onready var _player_camera: Camera2D = $PlayerCamera
@onready var _peek_camera: PeekCamera = $PeekCamera
@onready var _tile_map: TileMap = $TileMap
@onready var _health_ui: TextureRect = $UI/HealthCounter
@onready var _player_respawn_timer: Timer = $PlayerRespawnTimer

var game_stats: GameStats:
	set(value): _game_stats = value


func _ready() -> void:
	var ball_creature_scenes = find_children("*", "BallCreature")
	assert(ball_creature_scenes.size() > 0, "There is no ball create scene child!")
	ball_creature = ball_creature_scenes[0]

	assert(_player, "No player in the level!")

	_player_respawn_point = _player.global_position
	_player_tree_index = _player.get_index()

	_configure_player()
	_configure_basket()
	_configure_cameras()
	_register_checkpoints()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_peek_camera.make_current()


func _configure_basket() -> void:
	var basket_scene: Basket = find_child("Basket")
	assert(basket_scene, "No basket in the level!")
	basket_scene.ball_creature_captured.connect(_on_ball_creature_captured)

	if _game_stats:
		basket_scene.spawn_captured_creatures(_game_stats.saved_ball_creatures_colors)


func _configure_cameras() -> void:
	# Setting camera limits
	var tile_map_boundaries: = _tile_map.get_used_rect()
	var tile_map_cell_size: = _tile_map.rendering_quadrant_size

	for camera in [_player_camera, _peek_camera]:
		camera.limit_left = tile_map_boundaries.position.x * tile_map_cell_size + 2
		camera.limit_right = tile_map_boundaries.end.x * tile_map_cell_size - 2
		camera.limit_top = tile_map_boundaries.position.y * tile_map_cell_size + 2
		camera.limit_bottom = tile_map_boundaries.end.y * tile_map_cell_size - 2

	# Additional settings
	_peek_camera.ball_creature = ball_creature
	_peek_camera.arrived_at_player.connect(_on_peek_camera_at_player)


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
	if not _game_stats:
		return

	_game_stats.saved_ball_creatures_colors.append(ball_creature.color)
