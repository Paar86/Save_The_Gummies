class_name Checkpoint extends Area2D

signal checkpoint_activated(activated_checkpoint: Checkpoint)

var _bell_ring_sfx: Resource = preload(SfxResources.BELL_RING)
var _bell_falling_sfx: Resource = preload(SfxResources.BELL_FALLING)

var _sfx_resources: = {
	"bell_ring": preload(SfxResources.BELL_RING),
	"bell_falling": preload(SfxResources.BELL_FALLING),
	"ground_hit": preload(SfxResources.PLAYER_STOMP),
}

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func play_sound(sound_name: String) -> void:
	if not _sfx_resources.has(sound_name):
		push_error("Trying to play undefined sound!")
		return

	var sfx_resource: Resource = _sfx_resources[sound_name]
	AudioStreamManager2D.play_sound(sfx_resource, self)


func play_bell_ring_sound() -> void:
	AudioStreamManager2D.play_sound(_bell_ring_sfx, self)


func play_bell_falling_sound() -> void:
	AudioStreamManager2D.play_sound(_bell_falling_sfx, self)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	set_deferred("monitoring", false)
	_animation_player.play("activated")
	checkpoint_activated.emit(self)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "activated":
		_animation_player.play("bell_falling")
