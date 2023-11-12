class_name StarExplosion extends Node2D

const STAR_TRAVEL_DISTANCE: = 15.0

@onready var star_a: = $StarA
@onready var star_b: = $StarB
@onready var star_c: = $StarC
@onready var star_d: = $StarD

var stars_directions_dict: = {}


func _ready() -> void:
	_build_star_dictionary()

	# Interpolate all stars
	var tween: = get_tree().create_tween()

	for star in stars_directions_dict:
		tween.parallel().tween_property(
			star,
			"position",
			(star.position + stars_directions_dict[star]) * STAR_TRAVEL_DISTANCE,
			0.15
		)

	await tween.finished
	_on_tween_finished()


func _build_star_dictionary() -> void:
	stars_directions_dict = {
		star_a: Vector2(1.0, -1.0),
		star_b: Vector2(1.0, 1.0),
		star_c: Vector2(-1.0, -1.0),
		star_d: Vector2(-1.0, 1.0),
	}


func _on_tween_finished() -> void:
	queue_free()
