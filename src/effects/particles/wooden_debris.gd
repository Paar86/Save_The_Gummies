extends Node2D


func _ready() -> void:
	($MainParticles as GPUParticles2D).emitting = true
