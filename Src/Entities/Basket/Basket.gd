extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func on_creature_detector_body_entered(body: Node2D) -> void:
	animation_player.play("CREATURE_IN")
	print("Ball creature entered the basket!")
