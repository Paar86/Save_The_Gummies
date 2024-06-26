extends Node

const BUS := "Music"

var _music_player: AudioStreamPlayer
var _current_music_name := ""

@onready var playlist = {
	"start": preload("res://assets/music/start.wav"),
	"win": preload("res://assets/music/win.wav"),
	"title": preload("res://assets/music/title.ogg"),
	"credits": preload("res://assets/music/credits.ogg"),
	"level_a": preload("res://assets/music/level_a.ogg"),
	"level_b": preload("res://assets/music/level_b.ogg"),
	"level_c": preload("res://assets/music/level_c.ogg"),
	"level_d": preload("res://assets/music/level_d.ogg"),
	"level_e": preload("res://assets/music/level_e.ogg"),
}


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


func pause_music() -> void:
	_music_player.stream_paused = true


func unpause_music() -> void:
	_music_player.stream_paused = false


func stop_music() -> void:
	_current_music_name = ""
	_music_player.stop()


func stop_music_with_fadeout() -> void:
	_current_music_name = ""
	var original_volume = _music_player.volume_db

	var tween := get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(_music_player,
								"volume_db",
								-60.0,
								2.0)

	await tween.finished
	_music_player.stream_paused = true
	_music_player.volume_db = original_volume


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var music_player = AudioStreamPlayer.new()
	music_player.bus = BUS
	_music_player = music_player

	add_child(music_player)
