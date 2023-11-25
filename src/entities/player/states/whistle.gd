extends State

@export var character: CharacterBody2D
var _whistle_sfx: Resource = preload(SfxResources.PLAYER_WHISTLE)


func _ready() -> void:
	# We need to wait until the player node is ready so it has all onready properties initialized
	await owner.ready
	character.animation_player.animation_finished.connect(_on_animation_timeout)


func on_enter(params: StateParams) -> void:
	AudioStreamManager2D.play_sound(_whistle_sfx, character)
	state_machine.change_animation("whistle")
	character.animation_player.play("small_jump")


func _on_animation_timeout() -> void:
	state_machine.transition_to("Idle")
