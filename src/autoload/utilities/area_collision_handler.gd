extends Node


func get_collision_normals(
		monitoring_area: Area2D,
		monitoring_area_shape_index: int,
		colliding_area: Area2D,
		colliding_area_shape_index: int,
) -> Array[Vector2]:
	var local_shape_owner_id: = monitoring_area.shape_find_owner(monitoring_area_shape_index) as int
	var local_shape_owner_node: = monitoring_area.shape_owner_get_owner(local_shape_owner_id) as CollisionShape2D
	var local_shape: = local_shape_owner_node.shape as Shape2D

	var other_shape_owner_id: = colliding_area.shape_find_owner(colliding_area_shape_index) as int
	var other_shape_owner_node: = colliding_area.shape_owner_get_owner(other_shape_owner_id) as CollisionShape2D
	var other_shape: = other_shape_owner_node.shape as Shape2D

	var collision_contacts: PackedVector2Array = local_shape.collide_and_get_contacts(
		local_shape_owner_node.global_transform,
		other_shape,
		other_shape_owner_node.global_transform
	)

	var normal_vectors: Array[Vector2] = []
	var contact_from_above: = false
	# Every collision point consists of two collision contacts
	var number_of_contacts: = collision_contacts.size() / 2

	for i in number_of_contacts:
		var current_index: = i * 2
		var contact_point = collision_contacts[current_index]
		var other_contact_point = collision_contacts[current_index + 1]

		var normal_vector = (other_contact_point - contact_point).normalized()
		normal_vectors.append(normal_vector)

	return normal_vectors
