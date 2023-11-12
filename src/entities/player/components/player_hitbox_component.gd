extends HitboxComponent

var _stomp_sfx: Resource = preload("res://assets/sfx/player/player_stomp.wav")


func _on_area_shape_entered(
	area_rid: RID,
	area: Area2D,
	area_shape_index: int,
	local_shape_index: int
) -> void:
	if not is_valid_hurtbox(area):
		return

	var normals: = AreaCollisionHandler.get_collision_normals(
		self,
		local_shape_index,
		area,
		area_shape_index
	)

	# We need to know if player jumped on enemy from above
	var contact_from_above = false
	for normal in normals:
		if normal.dot(Vector2.UP) > 0.9:
			contact_from_above = true
			break

	if contact_from_above:
		Events.player_bounce_up_requested.emit()

		if area.owner is GameCharacter:
			(area.owner as GameCharacter).apply_effect(Enums.effect.STUNNED)

		if area.owner is Arrow:
			(area as HurtboxComponent).make_damage(1)

		AudioStreamManager2D.play_sound(_stomp_sfx, owner as Player)
