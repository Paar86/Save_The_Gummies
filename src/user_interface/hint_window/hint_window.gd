class_name HintWindow extends Control

signal hint_window_closed

const EMPTY_MESSAGE: = "<empty>"

var _is_window_opening: = false
var _key_icons_string: = {
	"*key_up*": "[img]res://assets/ui/icon_up.png[/img]",
	"*key_down*": "[img]res://assets/ui/icon_down.png[/img]",
	"*key_left*": "[img]res://assets/ui/icon_left.png[/img]",
	"*key_right*": "[img]res://assets/ui/icon_right.png[/img]",
	"*key_ctrl*": "[img]res://assets/ui/icon_ctrl.png[/img]",
	"*key_spacebar*": "[img]res://assets/ui/icon_spacebar.png[/img]",
	"*key_enter*": "[img]res://assets/ui/icon_enter.png[/img]",
}

@onready var _animated_border: = $AnimatedBorder as NinePatchRect
@onready var _hint_text: = $HintText as RichTextLabel
@onready var _animation_player: = $AnimationPlayer as AnimationPlayer
@onready var _hint_sfx: = preload(SfxResources.HINT_SHOW)


func _ready() -> void:
	if _hint_text.text:
		_hint_text.text = _replace_key_icons_strings(_hint_text.text)

	show()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	get_viewport().set_input_as_handled()
	_close_hint()


func show_hint(message: String) -> void:
	if not message:
		message = EMPTY_MESSAGE

	message = _replace_key_icons_strings(message)
	_hint_text.text = message

	_animated_border.show()
	_animation_player.play("grow")
	_is_window_opening = true

	AudioStreamManager.play_sound(_hint_sfx)


func _close_hint() -> void:
	set_process_input(false)
	_animated_border.hide()
	_hint_text.hide()
	hint_window_closed.emit()


func _replace_key_icons_strings(message: String) -> String:
	if not message:
		return message

	for key_string in _key_icons_string:
		message = message.replace(key_string, _key_icons_string[key_string])

	return message


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "grow":
		return

	set_process_input(true)
	_hint_text.show()

