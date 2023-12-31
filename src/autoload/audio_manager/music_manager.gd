extends Node

const BUS := "Music"

var _music_player: AudioStreamPlayer
var _current_music_name := ""

@onready var playlist = {}


func play_music(music_name: String) -> void:
	if music_name == _current_music_name:
		return

	_music_player.stop()

	if !playlist.has(music_name):
		push_warning("Music file with a name '%s' doesn't exist." % music_name)
		return

	_music_player.stream = playlist[music_name]
	_music_player.stream_paused = false
	_music_player.play()

	_current_music_name = music_name


func stop_music() -> void:
	_current_music_name = ""
	_music_player.stop()


func stop_music_with_fadeout() -> void:
	_current_music_name = ""
	var original_volume = _music_player.volume_db

	var tween := get_tree().create_tween()
	tween.interpolate_property(_music_player,
								"volume_db",
								_music_player.volume_db,
								-60.0,
								5.0,
								Tween.TRANS_LINEAR,
								Tween.EASE_OUT)
	tween.play()

	await tween.tween_all_completed
	_music_player.stream_paused = true
	_music_player.volume_db = original_volume


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var music_player = AudioStreamPlayer.new()
	music_player.bus = BUS
	_music_player = music_player

	add_child(music_player)
