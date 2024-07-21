extends Area2D

@onready var label = $Label
@onready var this_scene = $"/root/Menu"

var mouse_inside = false

var main_scene = preload("res://scenes/main.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_inside:
		label.modulate = Color(255, 0, 0)
		if Input.is_action_pressed("ui_click"):
			get_tree().root.add_child(main_scene)
			get_tree().root.remove_child(this_scene)
	else:
		label.modulate = Color(255, 255, 255)


func _on_mouse_entered():
	mouse_inside = true	

func _on_mouse_exited():
	mouse_inside = false
