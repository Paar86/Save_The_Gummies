extends State

@export var character: CharacterBody2D


func _ready() -> void:
	# We need to wait until the player node is ready so it has all onready properties initialized
	await owner.ready
	character.animation_player.animation_finished.connect(_on_kick_timeout)


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("kick")
	character.animation_player.play("small_jump")


func _on_kick_timeout(animation_name: String) -> void:
	state_machine.transition_to("Idle")
