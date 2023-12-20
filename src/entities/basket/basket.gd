class_name Basket extends StaticBody2D

signal ball_creature_captured(BallCreature)

const WAIT_TIME: = 2.0
const CREATURE_RADIUS: = 4.0

var _creature_packed: PackedScene = preload("res://src/entities/ball_creature/ball_creature_captured.tscn")

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _creature_detector: Area2D = $CreatureDetector
@onready var _spawn_boundary_left: Marker2D = $SpawnBoundaryLeft
@onready var _spawn_boundary_right: Marker2D = $SpawnBoundaryRight
@onready var _captured_creatures_node: Node = $CapturedCreatures

var _basket_catch_sfx: = preload(SfxResources.BASKET_CATCH)


## Gets spawn points as a dictionary of global positions and colors.
func get_creatures_spawn_points(creature_colors: Array[int]) -> Dictionary:
	var spawn_points_dict: Dictionary = {}
	if not creature_colors or creature_colors.size() == 0:
		return spawn_points_dict

	var spawn_interval: = _get_spawn_interval(creature_colors.size())
	var horizontal_spawn_origin: = _spawn_boundary_left.global_position.x + CREATURE_RADIUS
	for j in creature_colors.size():
		var horizontal_spawn_offset: = spawn_interval * j
		var spawn_point: = Vector2(
			horizontal_spawn_origin + horizontal_spawn_offset,
			_spawn_boundary_left.global_position.y - CREATURE_RADIUS
		).floor()

		spawn_points_dict[spawn_point] = creature_colors[j]

	return spawn_points_dict


func create_creature_instance(spawn_position: Vector2, color: int) -> Node2D:
	var creature_instance: = _creature_packed.instantiate() as BallCreatureCaptured
	creature_instance.position = spawn_position
	creature_instance.color = color
	creature_instance.animation_delay = randf()
	return creature_instance


func _get_spawn_interval(creatures_count: int) -> float:
	var spawn_boundary_left_x : = _spawn_boundary_left.position.x + CREATURE_RADIUS
	var spawn_boundary_right_x: = _spawn_boundary_right.position.x - CREATURE_RADIUS
	var spawn_boundary_y: = _spawn_boundary_left.position.y - CREATURE_RADIUS
	assert(spawn_boundary_left_x < spawn_boundary_right_x, "Left boundary must be to the left of the right boundary!")
	var spawn_area_distance: = spawn_boundary_right_x - spawn_boundary_left_x
	var spawn_interval: = spawn_area_distance / (creatures_count - 1) if creatures_count > 1 else spawn_area_distance

	return spawn_interval


func _on_creature_detector_body_entered(body: Node2D) -> void:
	if not body is BallCreature:
		return

	AudioStreamManager2D.play_sound(_basket_catch_sfx, self)

	_animation_player.play("CREATURE_IN")
	await get_tree().create_timer(WAIT_TIME).timeout
	if _creature_detector.overlaps_body(body):
		ball_creature_captured.emit(body)
		Events.change_level_requested.emit()
