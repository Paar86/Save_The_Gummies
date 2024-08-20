class_name Credits extends Control

const _INITIAL_DELAY: = 1
const _PAGE_FLIP_DELAY: = 4

var _pages_text: Array[String] = [
	"DEVELOPED BY

	Josef Sustek",
	"ADDITIONAL PROGRAMMING BY

	FlameShape",
	"MUSIC BY

	Dar Golan
	(dargolan.com)",
	"Thanks for playing!",
	"T H E  E N D"
]

var _current_page: = -1
var _can_interact: = false

@onready var _text: = $Text


func _unhandled_key_input(event: InputEvent) -> void:
	if _can_interact:
		_can_interact = false
		hide()
		await MusicManager.stop_music_with_fadeout()
		Events.change_scene_requested.emit()


func _ready() -> void:
	# Unpause the game as the scene loaded before could end in pause mode
	get_tree().paused = false
	MusicManager.play_music("credits")
	await get_tree().create_timer(_INITIAL_DELAY).timeout
	_flip_page()


func _flip_page() -> void:
	_current_page += 1
	_text.text = _pages_text[_current_page]

	await get_tree().create_timer(_PAGE_FLIP_DELAY).timeout

	# Go to another page
	if _current_page < _pages_text.size() - 1:
		_flip_page()
		return

	# Don't go to another pages, allow returning to main menu instead
	if _current_page == _pages_text.size() - 1:
		_can_interact = true
