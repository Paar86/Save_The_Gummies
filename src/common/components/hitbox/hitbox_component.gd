class_name HitboxComponent extends Area2D

signal damage_made(amount: int)

@export var damage: int = 1
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_shape_entered.connect(_on_area_shape_entered)


func is_valid_hurtbox(area: Area2D) -> bool:
	if area is HurtboxComponent:
		return true

	return false


func toggle_collision(value: bool) -> void:
	_collision_shape.set_deferred("disabled", !value)


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if not is_valid_hurtbox(area):
		return

	(area as HurtboxComponent).make_damage(damage)
	damage_made.emit(damage)
