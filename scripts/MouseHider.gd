extends Node

@export var time_to_hide: float = 3

var since_last_move: float = 0

func _process(delta: float) -> void:
	if since_last_move >= time_to_hide:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		since_last_move += delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		since_last_move = 0
