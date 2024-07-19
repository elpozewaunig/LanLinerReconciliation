extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var camera = $Camera2D

var speed = 800
var zoom_fact = 0.001
var current_lane = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
