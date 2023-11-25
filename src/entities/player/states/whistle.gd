extends State

@export var character: CharacterBody2D
var _whistle_sfx: Resource = preload(SfxResources.PLAYER_WHISTLE)


func on_enter(params: StateParams) -> void:
	character.animation_player.animation_finished.connect(_on_animation_timeout)
	AudioStreamManager2D.play_sound(_whistle_sfx, character)
	state_machine.change_animation("whistle")
	character.animation_player.play("small_jump")


func on_exit() -> void:
	character.animation_player.animation_finished.disconnect(_on_animation_timeout)


func _on_animation_timeout(animation_name: String) -> void:
	state_machine.transition_to("Idle")
