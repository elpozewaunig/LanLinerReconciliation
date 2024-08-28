extends Area2D
class_name Area2DButton

@export var sfx_enabled = true

var mouse_inside = false
var ext_selected = false
var highlight_enabled = false
signal clicked

@onready var hover_sfx = AudioStreamPlayer.new()
@onready var click_sfx = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up audio player nodes for UI sounds
	add_child(hover_sfx)
	add_child(click_sfx)
	hover_sfx.name = "HoverSFX"
	click_sfx.name = "ClickSFX"
	hover_sfx.stream = preload("res://assets/sounds/tick_002.ogg")
	click_sfx.stream = preload("res://assets/sounds/select_005.ogg")
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	clicked.connect(_on_clicked)
	clicked.connect(_on_super_clicked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if ((mouse_inside and not highlight_enabled) or(ext_selected and highlight_enabled)):
		modulate = Color(255, 0, 0)
		if (Input.is_action_just_pressed("ui_click") or Input.is_action_just_pressed("ui_accept")) and visible:
			emit_signal("clicked")
			
	else:
		modulate = Color(255, 255, 255)


func _on_mouse_entered():
	mouse_inside = true
	if sfx_enabled and is_inside_tree():
		hover_sfx.play()

func _on_mouse_exited():
	mouse_inside = false

# Triggered by button selector through key/gamepad input
func _on_ext_selected(btn_node):
	if visible:
		highlight_enabled = true
		if btn_node == self:
			ext_selected = true
			if sfx_enabled and is_inside_tree():
				hover_sfx.play()
		else:
			ext_selected = false

# Triggered by button selector when the current selection is replaced by mouse movement
func _on_ext_cleared():
	highlight_enabled = false
	if ext_selected:
		ext_selected = false

# Stuff that should always happen when the clicked signal is received
# Useful when a "click" is triggered through a controller
func _on_super_clicked():
	if sfx_enabled and is_inside_tree():
		click_sfx.play()

func _on_clicked():
	# This method should be implemented by subclasses
	pass
