extends State

@export var character: CharacterBody2D
var _kick_sfx: Resource = preload(SfxResources.PLAYER_KICK)


func on_enter(params: StateParams) -> void:
	character.animation_player.animation_finished.connect(_on_kick_timeout)
	AudioStreamManager2D.play_sound(_kick_sfx, character)
	state_machine.change_animation("kick")
	character.animation_player.play("small_jump")


func on_exit() -> void:
	character.animation_player.animation_finished.disconnect(_on_kick_timeout)


func _on_kick_timeout(animation_name: String) -> void:
	state_machine.transition_to("Idle")
