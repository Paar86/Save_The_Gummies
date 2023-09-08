extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D


func _ready() -> void:
	particles.emitting = true
