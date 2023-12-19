class_name BallCreatureCaptured extends Node2D

enum colors {
	BLUE_DARK_BLUE,
	GREEN_DARK_GREEN,
	YELLOW_DARK_YELLOW,
	MAGENTA_MAROON,
	PINK_MAROON,
	DARK_YELLOW_BROWN,
	WHEAT_YELLOW_BROWN
}

var animation_delay: = 0.0
var color: = colors.BLUE_DARK_BLUE:
	set(new_color):
		get_node("Sprite2D").get_material().set_shader_parameter("palette", new_color)
		color = new_color


@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _animation_delay_timer: Timer = $AnimationDelayTimer

func _ready() -> void:
	animation_delay = maxf(0.0, animation_delay)

	if not animation_delay:
		_animation_player.play("jumping")
		return

	_animation_delay_timer.wait_time = animation_delay
	_animation_delay_timer.start()


func _on_animation_delay_timer_timeout() -> void:
	_animation_player.play("jumping")
