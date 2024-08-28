extends Node2D

@export var buttons : Array[Area2DButton]

var highlight_active = false
var highlight_index = 0

signal ext_selected(btn_node)
signal ext_cleared

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect all buttons to the external selection signals
	for button in buttons:
		ext_selected.connect(button._on_ext_selected)
		ext_cleared.connect(button._on_ext_cleared)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var input = ""
	
	if Input.is_action_just_pressed("ui_up"):
		input = "up"
	elif Input.is_action_just_pressed("ui_down"):
		input = "down"
		
	if not input.is_empty():
		# Only enable highlight, if it was disabled
		if not highlight_active:
			highlight_active = true
			
		# Else, move the highlight (if the current button is visible)
		elif buttons[highlight_index].visible:
			if input == "up" && highlight_index > 0:
				highlight_index -= 1
			elif input == "down" && highlight_index < buttons.size() - 1:
				highlight_index += 1
				
		emit_signal("ext_selected", buttons[highlight_index])

func _input(event):
	if event is InputEventMouseMotion:
		highlight_active = false
		emit_signal("ext_cleared")
