class_name Barrier extends StaticBody2D

var _wooden_particles: PackedScene = preload("res://src/effects/particles/wooden_debris.tscn")
var _break_1_sfx: Resource = preload(SfxResources.BREAK_1)
var _break_2_sfx: Resource = preload(SfxResources.BREAK_2)

@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _sprite: Sprite2D = $Sprite2D

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox_shape: CollisionShape2D = $HurtboxComponent/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hurtbox_component.lives_changed.connect(_on_damage_taken)
	_hurtbox_component.lives_depleted.connect(_on_destroyed)


func _on_damage_taken(damage: int) -> void:
	AudioStreamManager2D.play_sound(_break_1_sfx, self)
	if _hurtbox_component.lives == 1:
		_sprite.frame = 1

	if _hurtbox_component.lives <= 0:
		_sprite.frame = 2

	var particles = _wooden_particles.instantiate()
	particles.position = _sprite.position
	add_child(particles)


func _on_destroyed() -> void:
	AudioStreamManager2D.play_sound(_break_2_sfx, self)
	_collision_shape.set_deferred("disabled", true)
	_hurtbox_shape.set_deferred("disabled", true)
