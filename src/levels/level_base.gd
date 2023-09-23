extends Node

signal camera_above_player

var ball_creature: BallCreature

@onready var player: Player = $Player
@onready var player_camera: Camera2D = $PlayerCamera
@onready var peek_camera: PeekCamera = $PeekCamera
@onready var tile_map: TileMap = $TileMap
@onready var health_ui: TextureRect = $UI/HealthCounter

func _ready() -> void:
	var ball_creature_scenes = find_children("*", "BallCreature")
	assert(ball_creature_scenes.size() > 0, "There is no ball create scene child!")
	ball_creature = ball_creature_scenes[0]

	# Setting camera limits
	var tile_map_boundaries: = tile_map.get_used_rect()
	var tile_map_cell_size: = tile_map.cell_quadrant_size

	for camera in [player_camera, peek_camera]:
		camera.limit_left = tile_map_boundaries.position.x * tile_map_cell_size + 2
		camera.limit_right = tile_map_boundaries.end.x * tile_map_cell_size - 2
		camera.limit_top = tile_map_boundaries.position.y * tile_map_cell_size + 2
		camera.limit_bottom = tile_map_boundaries.end.y * tile_map_cell_size - 2

	# Additional settings
	peek_camera.ball_creature = ball_creature
	peek_camera.arrived_at_player.connect(on_peek_camera_at_player)

	# Signals
	player.lives_changed.connect(health_ui.on_health_changed)
	health_ui.on_health_changed(player.get_current_lives())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		peek_camera.make_current()


func on_peek_camera_at_player() -> void:
	player_camera.make_current()
