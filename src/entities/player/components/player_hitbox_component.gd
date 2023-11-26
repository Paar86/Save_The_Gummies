extends HitboxComponent

var _stomp_sfx: Resource = preload(SfxResources.PLAYER_STOMP)


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
		# For player not jumping on enemy indefinitely
		if area.owner is GameCharacter and not (area.owner as GameCharacter).is_effect_active(Enums.effect.STUNNED):
			(area.owner as GameCharacter).apply_effect(Enums.effect.STUNNED)
		elif area.owner is Arrow:
			(area as HurtboxComponent).make_damage(1)
		else:
			return

		Events.player_bounce_up_requested.emit()
		AudioStreamManager2D.play_sound(_stomp_sfx, owner as Player)
