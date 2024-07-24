extends Node2D

@onready var left = $Left
@onready var right = $Right
@onready var up = $Up

var appearing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if appearing:
		show()
		modulate.a += delta * 2
		if modulate.a > 1:
			modulate.a = 1
	else:
		# Hide control options
		modulate.a -= delta * 3
		if modulate.a <= 0:
			modulate.a = 0
			hide()

func _on_choice_btn_pressed(btn):
	btn.scale.x = 2
	btn.scale.y = 2
	
