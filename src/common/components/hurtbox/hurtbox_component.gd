class_name HurtboxComponent extends Area2D

signal lives_changed(new_value: int)
signal lives_depleted
signal effects_propagated(effects: Array[String])

@export var lives = 99

var _collision_bitmask_default: int = 0


func _ready() -> void:
	# Remember the value for toggling the collision on/off
	_collision_bitmask_default = collision_layer


# To lower lives of the owner
func make_damage(damage: int) -> void:
	lives -= damage
	if lives <= 0:
		lives_changed.emit(lives)
		lives_depleted.emit()
	else:
		lives_changed.emit(lives)


# To propagate some effect on owner, e.g. stun
func propagate_effects(effects: Array[String]) -> void:
	effects_propagated.emit(effects)


# Toggle the collision layer on/off
func toggle_collider(value: bool) -> void:
	if value:
		collision_layer = _collision_bitmask_default
	else:
		collision_layer = 0
