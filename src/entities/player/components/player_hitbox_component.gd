extends HitboxComponent


func _on_area_shape_entered(
	area_rid: RID,
	area: Area2D,
	area_shape_index: int,
	local_shape_index: int
) -> void:
	if not is_valid_hurtbox(area):
		return

	var local_shape_owner_id: = shape_find_owner(local_shape_index) as int
	var local_shape_owner_node: = shape_owner_get_owner(local_shape_owner_id) as CollisionShape2D
	var local_shape: = local_shape_owner_node.shape as Shape2D

	var other_shape_owner_id: = area.shape_find_owner(area_shape_index) as int
	var other_shape_owner_node: = area.shape_owner_get_owner(other_shape_owner_id) as CollisionShape2D
	var other_shape: = other_shape_owner_node.shape as Shape2D

	var collision_contacts: PackedVector2Array = local_shape.collide_and_get_contacts(
		local_shape_owner_node.global_transform,
		other_shape,
		other_shape_owner_node.global_transform
	)

	var contact_from_above: = false
	var number_of_contacts: = collision_contacts.size() / 2

	# We need to know if player jumped on enemy from above
	for i in number_of_contacts:
		var current_index: = i * 2
		var contact_point = collision_contacts[current_index]
		var other_contact_point = collision_contacts[current_index + 1]

		var normal_vector = (other_contact_point - contact_point).normalized()
		if normal_vector.dot(Vector2.UP) > 0.9:
			contact_from_above = true
			break

	if contact_from_above:
		Events.player_bounce_up_requested.emit()
		(area.owner as GameCharacter).apply_effect(Enums.effect.STUNNED)
