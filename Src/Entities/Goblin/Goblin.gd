class_name Goblin extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var exclamation_mark: Sprite2D = $ExclamationMark


func get_facing_direction() -> float:
	return sign(animated_sprite.scale.x)


func toggle_exclamation_mark(value: bool) -> void:
	exclamation_mark.visible = value


func change_direction(new_direction: float) -> void:
	animated_sprite.scale.x = sign(new_direction)
