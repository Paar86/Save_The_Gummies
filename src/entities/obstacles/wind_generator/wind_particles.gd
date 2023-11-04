extends GPUParticles2D


func _ready() -> void:
	(process_material as ParticleProcessMaterial).gravity.x *= transform.x.x
