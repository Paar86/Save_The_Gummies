class_name CheerLabel extends Label

signal finished

const CHEER_TEXT_DEFAULT: = "<UNDEFINED TEXT>"
const FINISHED_DELAY: = 1.0

func show_cheer_text(cheer_text: String) -> void:
	if not cheer_text or cheer_text.length() == 0:
		cheer_text = CHEER_TEXT_DEFAULT

	text = cheer_text
	visible_characters = 0
	show()

	var tween: = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "visible_characters", cheer_text.length(), 0.20)
	await tween.finished

	if FINISHED_DELAY:
		await get_tree().create_timer(FINISHED_DELAY, true).timeout

	hide()
	finished.emit()
