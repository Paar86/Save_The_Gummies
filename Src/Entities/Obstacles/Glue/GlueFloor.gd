@tool
extends Area2D

@export var run_configuration: bool = false: set = _run_configuration
@onready var splash_container: Node = $GlueSplashContainer

var glue_splash_scene: PackedScene = preload("res://Src/Entities/Obstacles/Glue/GlueSplash.tscn")


func _run_configuration(value = null) -> void:
	var glue_start_sprite: Sprite2D = get_node("GlueFloorStart")
	var glue_middle_sprite: Sprite2D = get_node("GlueFloorMiddle")
	var glue_end_sprite: Sprite2D = get_node("GlueFloorEnd")

	if glue_start_sprite.position.y != glue_end_sprite.position.y:
		push_warning("Glue start and end sprites are not aligned vertically! Fixing!")

	var glue_start_end_distance: int = glue_end_sprite.position.x - glue_start_sprite.position.x
	if glue_start_end_distance % 8 != 0:
		push_warning("Glue start and end sprites are not spaced by multiplication of 8. Display error can occur!")

	var glue_middle_position_x: int =  (glue_start_end_distance / 2) + glue_start_sprite.position.x
	glue_middle_sprite.position.x = glue_middle_position_x
	glue_middle_sprite.position.y = glue_start_sprite.position.y

	glue_middle_sprite.region_rect.size = Vector2(glue_start_end_distance - 8, 8)

	# Setting collision shape
	var collision_shapes = find_children("*", "CollisionShape2D")
	for shape in collision_shapes:
		remove_child(shape)

	var collision_shape = create_collision_shape(
		glue_middle_sprite.position,
		Vector2(glue_start_end_distance + 8, 4),
		Vector2(4, -2)
	)

	add_child(collision_shape, true)
	collision_shape.owner = get_tree().edited_scene_root


func create_collision_shape(position: Vector2, size: Vector2, offset: Vector2) -> CollisionShape2D:
	var collisionShape = CollisionShape2D.new()
	var rectangleShape = RectangleShape2D.new()

	rectangleShape.size = size
	collisionShape.set_shape(rectangleShape)
	collisionShape.position = position + offset

	return collisionShape


func spawn_glue_splash(target_global_position: Vector2) -> void:
	var glue_splash: Node2D = glue_splash_scene.instantiate()
	glue_splash.global_position = target_global_position
	splash_container.add_child(glue_splash)
	get_tree().create_timer(2.0).timeout.connect(_on_glue_splash_timout.bind(glue_splash))


func _on_body_entered(body: PhysicsBody2D) -> void:
	spawn_glue_splash(body.global_position)

	if body is GameCharacter or body is BallCreature:
		body.apply_effect(Enums.effects.GLUED)


func _on_body_exited(body: Node2D) -> void:
	spawn_glue_splash(body.global_position)

	if body is GameCharacter or body is BallCreature:
		body.remove_effect(Enums.effects.GLUED)


func _on_glue_splash_timout(glue_splash: Node2D) -> void:
	glue_splash.queue_free()
