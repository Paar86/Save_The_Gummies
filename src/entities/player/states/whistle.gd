extends State

@export var character: Player
var _whistle_sfx: Resource = preload(SfxResources.PLAYER_WHISTLE)


func on_enter(params: StateParams) -> void:
	character.animation_player.animation_finished.connect(_on_animation_timeout)
	AudioStreamManager2D.play_sound(_whistle_sfx, character)
	state_machine.change_animation("whistle")
	character.animation_player.play("small_jump")

	for affected_body in character.whistle_affected_bodies:
		affected_body.propagate_whistle(character)


func on_exit(transition: Transition) -> void:
	character.animation_player.animation_finished.disconnect(_on_animation_timeout)


func _on_animation_timeout(animation_name: String) -> void:
	state_machine.transition_to("Idle")
