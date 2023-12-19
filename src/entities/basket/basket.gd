class_name Basket extends StaticBody2D

signal ball_creature_captured(BallCreature)

const WAIT_TIME: = 2.0

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _creature_detector: Area2D = $CreatureDetector

var _basket_catch_sfx: = preload(SfxResources.BASKET_CATCH)


func on_creature_detector_body_entered(body: Node2D) -> void:
	if not body is BallCreature:
		return

	AudioStreamManager2D.play_sound(_basket_catch_sfx, self)

	_animation_player.play("CREATURE_IN")
	await get_tree().create_timer(WAIT_TIME).timeout
	if _creature_detector.overlaps_body(body):
		ball_creature_captured.emit(body)
		Events.change_level_requested.emit()
