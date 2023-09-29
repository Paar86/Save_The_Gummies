extends Node2D

var _arrow_scene: PackedScene = preload("res://src/entities/obstacles/arrow_shooter/arrow.tscn")

@onready var _shooter_sprite: Sprite2D = $ShooterSprite
@onready var _arrows_folder: Node2D = $Arrows
@onready var _after_shot_timer: Timer = $AfterShotTimer
@onready var _prepare_timer: Timer = $PrepareTimer


func _ready() -> void:
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
	_after_shot_timer.start()


func _on_after_shot_timer_timeout() -> void:
	prepare_arrow()
