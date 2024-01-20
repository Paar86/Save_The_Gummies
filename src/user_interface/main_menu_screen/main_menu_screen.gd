class_name MainMenuScreen extends CanvasLayer

var level_count: int = 1

@onready var _menu_options: = $MenuOptions as MainMenuOptions


func _ready() -> void:
		_menu_options.level_count = level_count
		_menu_options.new_game_option_confirmed.connect(_on_new_game_option_confirmed)


func _on_new_game_option_confirmed(initial_level_number) -> void:
	Events.new_game_requested.emit(initial_level_number)
