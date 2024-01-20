class_name TitleScreen extends Node

const BALL_CRETURE_VISIBILITY_THRESHOLD: = 32
const BALL_CREATURE_CONSTANT_FORCE: = 300.0

var _initial_level_number: = 1
var _ball_creatures_all: Array[BallCreature] = []
@onready var _menu_options: = $MenuOptions as MainMenuOptions


func _ready() -> void:
	_ball_creatures_all.assign(find_children("*", "BallCreature"))
	#for ball_creature in _ball_creatures_all:
		#ball_creature.sleeping = true

	#set_process_input(false)
	set_physics_process(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_game_start()


func _physics_process(delta: float) -> void:
	# Destroy when not visible on screen
	for index in _ball_creatures_all.size():
		_check_ball_creature_visibility(index)

	if _are_all_creatures_freed():
		Events.change_scene_requested.emit()


func _check_ball_creature_visibility(index: int) -> void:
	var ball_creature: BallCreature = _ball_creatures_all[index]

	if not is_instance_valid(ball_creature):
		return

	if (
		ball_creature.position.x < -BALL_CRETURE_VISIBILITY_THRESHOLD
		or ball_creature.position.x > get_viewport().get_visible_rect().size.x + BALL_CRETURE_VISIBILITY_THRESHOLD
	):
		ball_creature.queue_free()


func _are_all_creatures_freed() -> bool:
	for creature in _ball_creatures_all:
		if is_instance_valid(creature):
			return false

	return true


func _on_game_start() -> void:
	set_physics_process(true)

	var viewport_half: float = get_viewport().get_visible_rect().size.x / 2
	for ball_creature in _ball_creatures_all:
		ball_creature.happy_mode_locked = false
		var modifier: = 1 if ball_creature.position.x < viewport_half else -1
		ball_creature.constant_force.x = BALL_CREATURE_CONSTANT_FORCE * modifier


func _show_start_game_prompt() -> void:
	#TODO: Show label
	set_process_input(true)


func _on_every_ball_creature_not_visible() -> void:
	Events.new_game_requested.emit(_initial_level_number)
