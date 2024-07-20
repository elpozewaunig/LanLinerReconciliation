extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var pathBuilder = $PathBuilder
	var path = pathBuilder.createPath()
	add_child(path)
	var player = player_scene.instantiate()
	add_child(player)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
