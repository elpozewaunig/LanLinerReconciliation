extends Area2D

var mouse_inside = false
signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mouse_inside:
		modulate = Color(255, 0, 0)
		if Input.is_action_pressed("ui_click"):
			emit_signal("clicked")
	else:
		modulate = Color(255, 255, 255)


func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false
