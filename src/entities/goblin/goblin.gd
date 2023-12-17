class_name Goblin extends GameCharacter

signal whistle_heard(direction: float)

var _facing_direction: = 1.0

@onready var player_detector: RayCast2D = $PlayerDetectorRayCast
@onready var state_machine: StateMachine = $StateMachine

@onready var _reaction_symbol: ReactionSymbol = $ReactionSymbol
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	super._ready()
	_facing_direction = sign(_animated_sprite.scale.x)
	_hurtbox_component.lives_depleted.connect(_on_lives_depleted)


func toggle_hurtbox_collider(value: bool) -> void:
	_hurtbox_component.toggle_collider(value)


func toggle_hitbox_collider(value: bool) -> void:
	player_detector.enabled = value
	_hitbox_component.set_collision_mask_value(2, value)


func change_direction(new_direction: float) -> void:
	_facing_direction = new_direction
	player_detector.scale.x = sign(new_direction)
	_animated_sprite.scale.x = sign(new_direction)
	_hitbox_component.set_deferred("position", Vector2(abs(_hitbox_component.position.x) * new_direction, _hitbox_component.position.y))


func propagate_whistle(source_body: GameCharacter) -> void:
	var source_body_direction: = source_body.global_position - global_position
	var whistle_direction_x: = sign(source_body_direction.x) as float
	whistle_heard.emit(whistle_direction_x)


func _on_lives_depleted() -> void:
	_generate_death_scene(_animated_sprite.global_position)
	queue_free()
