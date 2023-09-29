class_name Goblin extends GameCharacter

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _exclamation_mark: Sprite2D = $ExclamationMark
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _state_machine: StateMachine = $StateMachine
@onready var _player_detector: RayCast2D = $PlayerDetectorRayCast


func _ready() -> void:
	_hurtbox_component.effects_propagated.connect(on_effects_propagated)


func get_facing_direction() -> float:
	return sign(_animated_sprite.scale.x)


func toggle_exclamation_mark(value: bool) -> void:
	_exclamation_mark.visible = value


func toggle_hurtbox_collider(value: bool) -> void:
	_hurtbox_component.toggle_collider(value)


func toggle_hitbox_collider(value: bool) -> void:
	_player_detector.enabled = value
	_hitbox_component.set_collision_mask_value(2, value)


func change_direction(new_direction: float) -> void:
	_animated_sprite.scale.x = sign(new_direction)
	_player_detector.scale.x = sign(new_direction)
	_hitbox_component.set_deferred("position", Vector2(abs(_hitbox_component.position.x) * new_direction, _hitbox_component.position.y))


func on_effects_propagated(effects: Array[String]) -> void:
	_state_machine.current_state.propagate_effects(effects)
