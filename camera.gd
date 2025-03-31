extends Camera2D

var slow_time = false
@export var rect: ColorRect

func _process(delta):
	if slow_time:
		rect.material.shader = load("res://shaders/TimeStopMode.gdshader")
	else:
		rect.material.shader = load("res://shaders/NormalMode.gdshader")

	slow_time = false
	pass
