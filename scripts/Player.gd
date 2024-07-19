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
	progress += delta * speed * game_manager.tick_speed
	camera.zoom.x = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
	camera.zoom.y = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
