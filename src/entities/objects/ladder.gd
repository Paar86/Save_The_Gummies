@tool
extends Area2D

@export var run_configuration: bool = false: set = _run_configuration

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func get_ladder_boundaries_global() -> Rect2i:
	if not _collision_shape or not _collision_shape.shape:
		return Rect2i()

	var shape_rect: = _collision_shape.shape.get_rect()
	var shape_start_global_position: Vector2i = _collision_shape.global_position + shape_rect.position
	var shape_end_global_position: Vector2i = _collision_shape.global_position + shape_rect.end

	return Rect2i(shape_start_global_position, shape_rect.size)


func _run_configuration(value = null) -> void:
	var sprite_top: Sprite2D = get_node("SpriteTop")
	var sprite_middle: Sprite2D = get_node("SpriteMiddle")
	var sprite_bottom: Sprite2D = get_node("SpriteBottom")

	if sprite_top.position.y > sprite_bottom.position.y:
		push_warning("Top sprite should be above bottom sprite!")

	if sprite_top.position.x != sprite_bottom.position.x:
		push_warning("Top and bottom sprites are not aligned on x axis! Fixing!")
		sprite_bottom.position.x = sprite_top.position.x

	var top_bottom_distance: int = sprite_bottom.position.y - sprite_top.position.y
	if top_bottom_distance % 8 != 0:
		push_warning("Top or bottom sprite is not aligned properly to the 8x8 grid!")

	sprite_middle.position.x = sprite_top.position.x
	sprite_middle.position.y = sprite_top.position.y + top_bottom_distance / 2

	sprite_middle.region_rect.size = Vector2(8, top_bottom_distance - 8)

	# Setting collision shape
	var collision_shapes = find_children("*", "CollisionShape2D")
	for shape in collision_shapes:
		remove_child(shape)

	var utils = Utils.new()

	var collision_shape = utils.create_collision_shape(
		sprite_middle.position,
		Vector2(8.0, top_bottom_distance + 6.0),
		Vector2(0.0, 1.0)
	)

	add_child(collision_shape, true)
	collision_shape.owner = get_tree().edited_scene_root

	utils.free()
	run_configuration = false
