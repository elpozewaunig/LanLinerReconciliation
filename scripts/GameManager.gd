extends Node2D

var tick_speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var pathBuilder = $PathBuilder
	var player = $Player
	var path = pathBuilder.createPath()
	add_child(path)
	player.reparent(path)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
