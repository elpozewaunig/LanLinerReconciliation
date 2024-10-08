extends Node2D

@onready var player = preload("res://scenes/player.tscn").instantiate()
@onready var enemy = preload("res://scenes/enemy.tscn").instantiate()
@onready var music = $MusicPlayer

var tick_speed = 1
var branch_choices = []

var time_elapsed = 0
var enemy_spawned = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var pathBuilder = $PathBuilder
	var path = pathBuilder.createPath()
	add_child(path)
	add_child(player)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If the enemy hasn't spawned yet, increase a timer
	if !enemy_spawned:
		time_elapsed += delta
		# If the timer exceeds a specified time, spawn the enemy
		if time_elapsed > 1:
			add_child(enemy)
			music.play()
			enemy_spawned = true
