class_name ScreenShaker extends Node

var _cameras: Array[Camera2D] = []
var _frequency_timer: Timer
var _duration_timer: Timer
var _amplitude_current: = 0
var _priority_current: = 0


func _ready() -> void:
	_frequency_timer = Timer.new()
	_duration_timer = Timer.new()
	_frequency_timer.timeout.connect(_on_frequency_timer_timeout)
	_duration_timer.timeout.connect(_on_duration_timer_timeout)

	for timer: Timer in [_frequency_timer, _duration_timer]:
		timer.wait_time = 1.0
		add_child(timer)
		timer.owner = self

	Events.screen_shake_requested.connect(_on_shake_request)


func register_cameras(cameras: Array[Camera2D]) -> void:
	if not cameras:
		_cameras = []

	_cameras = cameras


func _start(
		duration: float,
		frequency: float,
		amplitude: float,
		priority: int
	) -> void:

	if priority < _priority_current:
		return

	_amplitude_current = amplitude
	_priority_current = priority

	_duration_timer.wait_time = duration
	_frequency_timer.wait_time = 1 / frequency

	_duration_timer.start()
	_frequency_timer.start()

	_new_shake()


func _new_shake() -> void:
	var rand_offset_y: = 0.0
	rand_offset_y = randi_range(-_amplitude_current, _amplitude_current)

	for camera in _cameras:
		var tween: = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "offset:y", rand_offset_y, _frequency_timer.wait_time)


func _reset() -> void:
	for camera in _cameras:
		var tween: = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "offset:y", 0.0, _frequency_timer.wait_time)

	_priority_current = 0


func _on_frequency_timer_timeout() -> void:
	_new_shake()


func _on_duration_timer_timeout() -> void:
	_frequency_timer.stop()
	_reset()

func _on_shake_request(amplitude: float = 3.0, duration: float = 0.2, priority: int = 1) -> void:
	_start(duration, 60.0, amplitude, priority)
