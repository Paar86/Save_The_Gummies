extends Node

signal camera_above_player

var ball_creature: BallCreature
var _checkpoints: Array[Checkpoint] = []
var _player_respawn_point: = Vector2.ZERO

@onready var _player: Player = $Player
@onready var _player_camera: Camera2D = $PlayerCamera
@onready var _peek_camera: PeekCamera = $PeekCamera
@onready var _tile_map: TileMap = $TileMap
@onready var _health_ui: TextureRect = $UI/HealthCounter


func _ready() -> void:
	var ball_creature_scenes = find_children("*", "BallCreature")
	assert(ball_creature_scenes.size() > 0, "There is no ball create scene child!")
	ball_creature = ball_creature_scenes[0]

	# Signals
	_player.lives_changed.connect(_health_ui.on_health_changed)
	_health_ui.on_health_changed(_player.get_current_lives())
	_health_ui.show()

	# Player
	_player_respawn_point = _player.global_position

	_configure_cameras()
	_register_checkpoints()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_peek_camera.make_current()


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
	_checkpoints.sort_custom(func(ch1, ch2): return ch2.name > ch1.name)

	for checkpoint in _checkpoints:
		checkpoint.checkpoint_activated.connect(_on_checkpoint_activated)


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
