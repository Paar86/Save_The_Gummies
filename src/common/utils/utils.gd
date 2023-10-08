class_name Utils extends Node


# Position: Initial position of the collision shape
# Size: Extents of the collision shape
# Offset: Optional offset for the initial position
func create_collision_shape(
		position: Vector2 = Vector2.ZERO,
		size: Vector2 = Vector2(8.0, 8.0),
		offset: Vector2 = Vector2.ZERO
) -> CollisionShape2D:
	var collisionShape = CollisionShape2D.new()
	var rectangleShape = RectangleShape2D.new()

	rectangleShape.size = size
	collisionShape.set_shape(rectangleShape)
	collisionShape.position = position + offset

	return collisionShape
