@tool
extends Area2D

@export var run_configuration: bool = false: set = _run_configuration

var _glue_splash_scene: PackedScene = preload("res://src/entities/obstacles/glue/glue_splash.tscn")
var _glue_splash_in_sfx: Resource = preload(SfxResources.GLUE_SPLASH_IN)
var _glue_splash_out_sfx: Resource = preload(SfxResources.GLUE_SPLASH_OUT)

@onready var splash_container: Node = $GlueSplashContainer


func spawn_glue_splash(target_global_position: Vector2) -> void:
	var glue_splash: Node2D = _glue_splash_scene.instantiate()
	glue_splash.global_position = target_global_position
	splash_container.add_child(glue_splash)
	get_tree().create_timer(2.0).timeout.connect(_on_glue_splash_timout.bind(glue_splash))


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

	var utils = Utils.new()

	var collision_shape = utils.create_collision_shape(
		glue_middle_sprite.position,
		Vector2(glue_start_end_distance + 8, 8),
		Vector2(4, -2)
	)

	add_child(collision_shape, true)
	collision_shape.owner = get_tree().edited_scene_root
	utils.free()


func _on_body_entered(body: PhysicsBody2D) -> void:
	spawn_glue_splash(body.global_position)

	if body is GameCharacter or body is BallCreature:
		body.apply_effect(Enums.effect.GLUED)

	AudioStreamManager2D.play_sound(_glue_splash_in_sfx, body)


func _on_body_exited(body: Node2D) -> void:
	spawn_glue_splash(body.global_position)

	if body is GameCharacter or body is BallCreature:
		body.remove_effect(Enums.effect.GLUED)

	AudioStreamManager2D.play_sound(_glue_splash_out_sfx, body)


func _on_glue_splash_timout(glue_splash: Node2D) -> void:
	glue_splash.queue_free()
