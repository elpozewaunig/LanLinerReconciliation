extends Area2D

@onready var label = $Label

var mouse_inside = false

var main_scene = preload("res://scenes/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mouse_inside:
		label.modulate = Color(255, 0, 0)
		if Input.is_action_pressed("ui_click"):
			get_tree().change_scene_to_packed(main_scene)
	else:
		label.modulate = Color(255, 255, 255)


func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false
