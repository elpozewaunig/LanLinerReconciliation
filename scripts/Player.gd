extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var camera = $Camera2D

var speed = 100
var zoom_fact = 0.001


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var change = delta * speed * game_manager.tick_speed
	var change_ratio  = change / get_parent().curve.get_baked_length()
	if progress_ratio + change_ratio >= 1:
		progress += change
		var next = get_parent().get_child(1)
		reparent(next)
		progress_ratio -= 1
	else:
		progress += change
	camera.zoom.x = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
	camera.zoom.y = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
