class_name TransitionLayer extends CanvasLayer

signal transition_finished

const TRANSITION_DURATION: = 1.0

@onready var _color_rect: = $ColorRect as ColorRect


func start_transition_effect(starting_value: float, target_value: float, duration: float = TRANSITION_DURATION) -> void:
	show()
	var tween: = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_shader_param_value, starting_value, target_value, duration)
	await tween.finished
	hide()
	transition_finished.emit()


func _set_shader_param_value(value: float) -> void:
	var shader_material: = (_color_rect.material as ShaderMaterial)
	shader_material.set_shader_parameter("cutoff_value", value)
