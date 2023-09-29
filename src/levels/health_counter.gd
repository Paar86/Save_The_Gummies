extends TextureRect

# Width in pixels
var _heart_sprite_width: int = 8


func on_health_changed(new_value: int) -> void:
	# The texture size cannot be smaller than used sprite so we hide it instead
	if !new_value:
		hide()

	size.x = _heart_sprite_width * new_value
