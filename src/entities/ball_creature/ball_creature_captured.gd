class_name BallCreatureCaptured extends Node2D

var animation_delay: = 0.0
var color: int:
	set(new_color):
		if _sprite:
			_sprite.color = new_color

		color = new_color


@onready var _sprite: PalettedSprite = $PalettedSprite
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _animation_delay_timer: Timer = $AnimationDelayTimer


func _ready() -> void:
	_sprite.color = color
	animation_delay = maxf(0.0, animation_delay)

	if not animation_delay:
		_animation_player.play("jumping")
		return

	_animation_delay_timer.wait_time = animation_delay
	_animation_delay_timer.start()


func _on_animation_delay_timer_timeout() -> void:
	_animation_player.play("jumping")
