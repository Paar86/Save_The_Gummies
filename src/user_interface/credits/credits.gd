extends CanvasLayer

const TEXT_SPEED: = 0.4
const START_WAIT_TIME: = 1.5
const END_WAIT_TIME: = 1.0

@onready var credits_pivot: Control = $Control/Pivot
@onready var credits_text: Label = $Control/Pivot/CreditsText

var _move: bool = false


func _ready() -> void:
	await get_tree().create_timer(START_WAIT_TIME).timeout
	_move = true


func _physics_process(delta: float) -> void:
	if _move:
		credits_pivot.position.y -= TEXT_SPEED
	if credits_text.global_position.y + credits_text.size.y < 0:
		await get_tree().create_timer(END_WAIT_TIME).timeout
		Events.change_level.emit()
