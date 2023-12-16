extends Node

signal camera_above_player

var ball_creature: BallCreature

@onready var _player: Player = $Player
@onready var _player_camera: Camera2D = $PlayerCamera
@onready var _peek_camera: PeekCamera = $PeekCamera
@onready var _tile_map: TileMap = $TileMap
@onready var _health_ui: TextureRect = $UI/HealthCounter


func _ready() -> void:
	var ball_creature_scenes = find_children("*", "BallCreature")
	assert(ball_creature_scenes.size() > 0, "There is no ball create scene child!")
	ball_creature = ball_creature_scenes[0]

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

	# Signals
	_player.lives_changed.connect(_health_ui.on_health_changed)
	_health_ui.on_health_changed(_player.get_current_lives())
	_health_ui.show()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_peek_camera.make_current()


func _on_peek_camera_at_player() -> void:
	_player_camera.make_current()
