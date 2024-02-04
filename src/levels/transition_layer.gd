class_name TransitionLayer extends CanvasLayer

signal transition_finished

const TRANSITION_DURATION: = 1.0
const TRANSITION_DELAY: = 1.0

@onready var _color_rect: = $ColorRect as ColorRect


func start_transition_effect(
	starting_value: float,
	target_value: float,
	hide_after_finished: bool = true,
	duration: float = TRANSITION_DURATION
) -> void:
	show()

	await get_tree().create_timer(TRANSITION_DELAY, true).timeout
	var tween: = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_shader_param_value, starting_value, target_value, duration)
	await tween.finished

	if hide_after_finished:
		# Optimalization so Godot doesn't even try to draw the rect
		hide()
	else:
		# Used for "curtain closing" effect so the resulting black square stayes there for a while
		await get_tree().create_timer(TRANSITION_DELAY, true).timeout

	transition_finished.emit()


func _set_shader_param_value(value: float) -> void:
	var shader_material: = (_color_rect.material as ShaderMaterial)
	shader_material.set_shader_parameter("cutoff_value", value)
