class_name HintSignpost extends Area2D

signal hint_message_requested(String)

var _is_player_near: = false

@export_multiline var hint_message: = ""
@onready var _up_key_sprite: = $UpKeySprite as Sprite2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") and _is_player_near:
		hint_message_requested.emit(hint_message)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	_up_key_sprite.show()
	_is_player_near = true


func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return

	_up_key_sprite.hide()
	_is_player_near = false
