extends HitboxComponent

# How fast has the creature to move to make damage
const DAMAGE_VELOCITY_THRESHOLD: = 160.0

var attack_velocity_strength: float = 0.0
@export var _ball_creature: BallCreature


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if not is_valid_hurtbox(area):
		return

	if attack_velocity_strength < DAMAGE_VELOCITY_THRESHOLD:
		return

	(area as HurtboxComponent).make_damage(damage)
	damage_made.emit(damage, area)
