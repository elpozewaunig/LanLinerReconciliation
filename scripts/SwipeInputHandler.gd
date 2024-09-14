extends Node2D

@export var threshold : int = 150

var start_pos : Vector2
var end_pos : Vector2
var swiping = false
var already_handled = false

signal swipe_left
signal swipe_right
signal swipe_up

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Gesture started
	if Input.is_action_just_pressed("ui_click"):
		already_handled = false
		start_pos = get_global_mouse_position()

	# While dragging
	if Input.is_action_pressed("ui_click"):
		end_pos = get_global_mouse_position()
		if !already_handled:
			already_handled = true
			if end_pos.x < start_pos.x - threshold:
				swipe_left.emit()
			elif end_pos.x > start_pos.x + threshold:
				swipe_right.emit()
			elif end_pos.y < start_pos.y - threshold:
				swipe_up.emit()
			else:
				already_handled = false
