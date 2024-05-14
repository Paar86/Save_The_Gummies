class_name Crusher extends Node2D

@onready var _chain_l: = $ChainL as Line2D
@onready var _chain_r: = $ChainR as Line2D
@onready var _main_body: = $MainBody as CrusherMainBody

func _ready() -> void:
	_main_body.body_moved.connect(_on_main_body_moved, CONNECT_DEFERRED)
	_update_chain_lines()


func _update_chain_lines() -> void:
	# We need to round the positions as they jitter otherwise
	for chain: Line2D in [_chain_l, _chain_r]:
			chain.set_point_position(0, Vector2(0, _main_body.position.y).floor())


func _on_main_body_moved() -> void:
	_update_chain_lines()


func _on_player_detector_area_body_entered(body: Node2D) -> void:
	_main_body.react_to_player_detection()


func _on_player_detector_area_body_exited(body: Node2D) -> void:
	_main_body.react_to_player_left_detector()
