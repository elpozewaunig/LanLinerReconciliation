extends Node2D

@export var buttons : Array[Area2DButton]

var highlight_active = false
var highlight_index = 0

signal ext_selected(btn_node)
signal ext_cleared

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		# Connect all buttons to the external selection signals
		ext_selected.connect(button._on_ext_selected)
		ext_cleared.connect(button._on_ext_cleared)
		
		# Connect self to button's select signal
		button.selected.connect(_on_btn_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var input = ""
	
	if Input.is_action_just_pressed("ui_up"):
		input = "up"
	elif Input.is_action_just_pressed("ui_down"):
		input = "down"
	
	# If input has been pressed and the current button is visible
	if not input.is_empty() and buttons[highlight_index].visible and is_visible_in_tree():
		# If a selector highlight is currently active
		# Or the mouse points to the current selection
		if highlight_active or buttons[highlight_index].mouse_inside:
			# Move the highlight respectively
			if input == "up" && highlight_index > 0:
				highlight_index -= 1
			elif input == "down" && highlight_index < buttons.size() - 1:
				highlight_index += 1
		
		# Else only set the highlight to active so in the next pass it will move
		highlight_active = true		
		emit_signal("ext_selected", buttons[highlight_index])

func _input(event):
	if event is InputEventMouseMotion:
		highlight_active = false
		emit_signal("ext_cleared")

func _on_btn_selected(btn_node):
	if not highlight_active:
		for i in range(0, buttons.size()):
			if buttons[i] == btn_node:
				highlight_index = i
