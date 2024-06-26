class_name MainMenuOptions extends Control

signal new_game_option_confirmed(int)

var level_count: = 1

var _horizontal_funcs: = {
	0: func(add_number: int): return,
	1: _change_level_choice,
}

var _accept_funcs: = {
	0: _start_new_game,
	1: func(): return,
}

var _menu_options: Array[HBoxContainer]
var _level_choice_current: = 1
var _cursor_position_current: = 0:
	set(value):
		var original_position: = _cursor_position_current

		if value < 0:
			_cursor_position_current = _menu_options.size() - 1
		elif value > _menu_options.size() - 1:
			_cursor_position_current = 0
		else:
			_cursor_position_current = value

		_on_option_entered(_cursor_position_current)
		_on_option_exited(original_position)
		_cursor.global_position = Vector2(10.0, _menu_options[_cursor_position_current].global_position.y)
		AudioStreamManager.play_sound(_cursor_move_sfx, -6.0)
	get:
		return _cursor_position_current

@onready var _cursor_move_sfx: = preload(SfxResources.CURSOR_MOVE)
@onready var _confirm_sfx: = preload(SfxResources.CONFIRM_2)
@onready var _cursor: = $Cursor as Control
@onready var _left_marker: = $OptionsContainer/SelectLevelOption/LeftMarker as Label
@onready var _right_marker: = $OptionsContainer/SelectLevelOption/RightMarker as Label
@onready var _level_number: = $OptionsContainer/SelectLevelOption/LevelNumber as Label


func _ready() -> void:
	_menu_options.assign(find_children("*Option", "HBoxContainer"))
	_cursor.show()
	_cursor.global_position = Vector2(10.0, _menu_options[0].global_position.y)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_cursor_position_current -= 1

	if event.is_action_pressed("ui_down"):
		_cursor_position_current += 1

	if event.is_action_pressed("ui_right"):
		_horizontal_funcs[_cursor_position_current].call(1)

	if event.is_action_pressed("ui_left"):
		_horizontal_funcs[_cursor_position_current].call(-1)

	if event.is_action_pressed("ui_accept"):
		_accept_funcs[_cursor_position_current].call()


func _change_level_choice(add_number: int) -> void:
	var new_level_choice: = _level_choice_current + add_number
	if new_level_choice > level_count or new_level_choice < 1:
		return

	_level_number.text = str(new_level_choice)
	_level_choice_current = new_level_choice
	_left_marker.modulate.a = 1.0
	_right_marker.modulate.a = 1.0

	if new_level_choice == 1:
		_left_marker.modulate.a = 0.0

	if new_level_choice == level_count:
		_right_marker.modulate.a = 0.0

	AudioStreamManager.play_sound(_cursor_move_sfx, -6.0)


func _start_new_game() -> void:
	new_game_option_confirmed.emit(_level_choice_current)
	set_process_input(false)
	hide()
	AudioStreamManager.play_sound(_confirm_sfx)


func _on_option_entered(index: int) -> void:
	match index:
		1:
			_left_marker.show()
			_right_marker.show()


func _on_option_exited(index: int) -> void:
	match index:
		1:
			_left_marker.hide()
			_right_marker.hide()
