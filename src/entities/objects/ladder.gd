extends Area2D

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func get_ladder_boundaries_global() -> Rect2i:
	if not _collision_shape or not _collision_shape.shape:
		return Rect2i()

	var shape_rect: = _collision_shape.shape.get_rect()
	var shape_start_global_position: Vector2i = _collision_shape.global_position + shape_rect.position
	var shape_end_global_position: Vector2i = _collision_shape.global_position + shape_rect.end

	return Rect2i(shape_start_global_position, shape_rect.size)
