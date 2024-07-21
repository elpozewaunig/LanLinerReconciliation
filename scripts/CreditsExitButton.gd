extends Area2D

@onready var sprite = $Sprite2D
@onready var credits = $"/root/Menu/UI/Credits"

var mouse_inside = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_inside:
		sprite.modulate = Color(255, 0, 0)
		if Input.is_action_pressed("ui_click"):
			credits.hide()
	else:
		sprite.modulate = Color(255, 255, 255)


func _on_mouse_entered():
	mouse_inside = true	

func _on_mouse_exited():
	mouse_inside = false
