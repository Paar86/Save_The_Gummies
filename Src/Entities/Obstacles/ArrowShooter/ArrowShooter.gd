extends Node2D

@onready var shooter_sprite: Sprite2D = $ShooterSprite
@onready var arrows_folder: Node2D = $Arrows
@onready var after_shot_timer: Timer = $AfterShotTimer
@onready var prepare_timer: Timer = $PrepareTimer

var arrow_scene: PackedScene = preload("res://Src/Entities/Obstacles/ArrowShooter/Arrow.tscn")


func _ready() -> void:
	prepare_arrow()


func prepare_arrow() -> void:
	var new_arrow: Arrow = arrow_scene.instantiate()
	new_arrow.process_mode = Node.PROCESS_MODE_DISABLED

	new_arrow.position = shooter_sprite.position
	arrows_folder.add_child(new_arrow)
	new_arrow.owner = self

	prepare_timer.start()
	await prepare_timer.timeout

	new_arrow.process_mode = Node.PROCESS_MODE_INHERIT
	after_shot_timer.start()


func _on_after_shot_timer_timeout() -> void:
	prepare_arrow()
