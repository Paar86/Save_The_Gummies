class_name Goblin extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var exclamation_mark: Sprite2D = $ExclamationMark
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	hurtbox_component.effects_propagated.connect(on_effects_propagated)


func get_facing_direction() -> float:
	return sign(animated_sprite.scale.x)


func toggle_exclamation_mark(value: bool) -> void:
	exclamation_mark.visible = value


func toggle_hurtbox_collider(value: bool) -> void:
	hurtbox_component.toggle_collider(value)


func change_direction(new_direction: float) -> void:
	animated_sprite.scale.x = sign(new_direction)


func on_effects_propagated(effects: Array[String]) -> void:
	state_machine.current_state.propagate_effects(effects)
