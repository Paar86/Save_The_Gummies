extends Node2D

@export var delay_time: = 0.0

var _arrow_scene: PackedScene = preload("res://src/entities/obstacles/arrow_shooter/arrow.tscn")
var _arrow_shoot_sfx: Resource = preload(SfxResources.ARROW_SHOOT)

@onready var _shooter_sprite: Sprite2D = $ShooterSprite
@onready var _arrows_folder: Node2D = $Arrows
@onready var _delay_timer: Timer = $DelayTimer
@onready var _after_shot_timer: Timer = $AfterShotTimer
@onready var _prepare_timer: Timer = $PrepareTimer


func _ready() -> void:
	if delay_time:
		_delay_timer.wait_time = delay_time
		_delay_timer.start()
		await _delay_timer.timeout

	prepare_arrow()


func prepare_arrow() -> void:
	var new_arrow: Arrow = _arrow_scene.instantiate()
	new_arrow.process_mode = Node.PROCESS_MODE_DISABLED

	new_arrow.position = _shooter_sprite.position
	_arrows_folder.add_child(new_arrow)
	new_arrow.owner = self

	_prepare_timer.start()
	await _prepare_timer.timeout

	new_arrow.process_mode = Node.PROCESS_MODE_INHERIT
	AudioStreamManager2D.play_sound(_arrow_shoot_sfx, self)
	_after_shot_timer.start()


func _on_after_shot_timer_timeout() -> void:
	prepare_arrow()
