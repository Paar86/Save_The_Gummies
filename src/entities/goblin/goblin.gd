class_name Goblin extends GameCharacter

@onready var player_detector: RayCast2D = $PlayerDetectorRayCast
@onready var state_machine: StateMachine = $StateMachine
@onready var exclamation_mark: Sprite2D = $ExclamationMark

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	_hurtbox_component.effects_propagated.connect(_on_effects_propagated)
	_hurtbox_component.lives_depleted.connect(_on_lives_depleted)


func get_facing_direction() -> float:
	return sign(_animated_sprite.scale.x)


func toggle_exclamation_mark(value: bool) -> void:
	exclamation_mark.visible = value


func toggle_hurtbox_collider(value: bool) -> void:
	_hurtbox_component.toggle_collider(value)


func toggle_hitbox_collider(value: bool) -> void:
	player_detector.enabled = value
	_hitbox_component.set_collision_mask_value(2, value)


func change_direction(new_direction: float) -> void:
	player_detector.scale.x = sign(new_direction)
	_animated_sprite.scale.x = sign(new_direction)
	_hitbox_component.set_deferred("position", Vector2(abs(_hitbox_component.position.x) * new_direction, _hitbox_component.position.y))


func _on_effects_propagated(effects: Array[String]) -> void:
	state_machine.current_state.propagate_effects(effects)


func _on_lives_depleted() -> void:
	queue_free()
