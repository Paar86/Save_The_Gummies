extends HitboxComponent


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if not is_valid_hurtbox(area):
		return

	(area as HurtboxComponent).make_damage(1)
