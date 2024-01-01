@tool
class_name Goblin extends GameCharacter

signal whistle_heard(direction: float)

## Flips the horizontal orientation of the enemy in editor.
@export var change_direction_in_editor: bool:
	set(value):
		# We must make children editable for the changes to make an effect
		get_parent().set_editable_instance(self, true);
		var facing_direction = sign(_animated_sprite.scale.x) * -1
		change_direction(facing_direction)

var is_near_obstacle: bool:
	get:
		return obstacle_detector.is_colliding() or obstacle_detector_2.is_colliding()

var _facing_direction: = 1.0

@onready var player_detector: RayCast2D = $PlayerDetectorRayCast
@onready var state_machine: StateMachine = $StateMachine
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var obstacle_detector: RayCast2D = $ObstacleDetector
@onready var obstacle_detector_2: RayCast2D = $ObstacleDetector2

@onready var _reaction_symbol: ReactionSymbol = $ReactionSymbol
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	super._ready()
	_facing_direction = sign(_animated_sprite.scale.x)
	_hurtbox_component.lives_depleted.connect(_on_lives_depleted)


func toggle_hurtbox_collider(value: bool) -> void:
	_hurtbox_component.toggle_collider(value)


func toggle_hitbox_collider(value: bool) -> void:
	player_detector.enabled = value
	_hitbox_component.set_collision_mask_value(2, value)


func change_direction(new_direction: float) -> void:
	(func():
		_facing_direction = new_direction
		player_detector.scale.x = sign(new_direction)
		obstacle_detector.scale.x = sign(new_direction)
		obstacle_detector_2.scale.x = sign(new_direction)
		_animated_sprite.scale.x = sign(new_direction)
		_hitbox_component.position = Vector2(abs(_hitbox_component.position.x) * new_direction, _hitbox_component.position.y)
		ground_detector.position = Vector2(abs(ground_detector.position.x) * new_direction, ground_detector.position.y)
	).call_deferred()


func propagate_whistle(source_body: GameCharacter) -> void:
	var source_body_direction: = source_body.global_position - global_position
	var whistle_direction_x: = sign(source_body_direction.x) as float
	if whistle_direction_x == 0:
		whistle_direction_x = 1.0

	whistle_heard.emit(whistle_direction_x)


func _on_lives_depleted() -> void:
	_generate_death_scene(_animated_sprite.global_position)
	queue_free()
