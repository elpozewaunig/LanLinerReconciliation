extends Area2D
class_name Area2DButton

@export var sfx_enabled = true

var mouse_inside = false
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mouse_inside:
		modulate = Color(255, 0, 0)
		if Input.is_action_just_pressed("ui_click"):
			emit_signal("clicked")
			if sfx_enabled and is_inside_tree():
				click_sfx.play()
	else:
		modulate = Color(255, 255, 255)


func _on_mouse_entered():
	mouse_inside = true
	if sfx_enabled and is_inside_tree():
		hover_sfx.play()

func _on_mouse_exited():
	mouse_inside = false

func _on_clicked():
	# This method should be implemented by subclasses
	pass
