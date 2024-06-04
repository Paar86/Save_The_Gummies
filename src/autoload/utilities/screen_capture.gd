extends Node


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("screen_capture"):
		take_screenshot()


func take_screenshot(): # Function for taking screenshots and saving them

	var date = Time.get_date_string_from_system().replace(".","_")
	var time: String = Time.get_time_string_from_system().replace(":","")
	var screenshot_path = "user://" + "screenshot_" + date+ "_" + time + ".png" # the path for our screenshot.

	var image = get_viewport().get_texture().get_image() # We get what our player sees

	image.save_png(screenshot_path)
	print("Screenshot taken...")

