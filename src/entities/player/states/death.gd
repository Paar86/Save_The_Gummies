extends State

@export var character: Player


func on_enter(params: StateParams) -> void:
	character._generate_death_scene(character._player_animated_sprite.global_position)
	character.lives_depleted.emit()
	character.queue_free()
