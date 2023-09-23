extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func get_ladder_boundaries_global() -> Rect2i:
	if not collision_shape or not collision_shape.shape:
		return Rect2i()

	var shape_rect: = collision_shape.shape.get_rect()
	var shape_start_global_position: Vector2i = collision_shape.global_position + shape_rect.position
	var shape_end_global_position: Vector2i = collision_shape.global_position + shape_rect.end

	return Rect2i(shape_start_global_position, shape_rect.size)
