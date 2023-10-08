class_name Barrier extends StaticBody2D

@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hurtbox_component.lives_changed.connect(_on_damage_taken)
	_hurtbox_component.lives_depleted.connect(_on_destroyed)


func _on_damage_taken(damage: int) -> void:
	if _hurtbox_component.lives > 0:
		_sprite.frame = 1


func _on_destroyed() -> void:
	queue_free()
