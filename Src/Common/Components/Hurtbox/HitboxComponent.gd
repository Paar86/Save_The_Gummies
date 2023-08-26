class_name HitboxComponent extends Area2D


func _ready() -> void:
	area_shape_entered.connect(on_area_shape_entered)


func is_valid_hurtbox(area: Area2D) -> bool:
	if area is HurtboxComponent:
		return true

	return false


func on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
