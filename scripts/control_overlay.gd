extends Node2D

@onready var game_manager = $"/root/GameManager"

@onready var left = $Left
@onready var right = $Right
@onready var up = $Up


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = game_manager.player
	global_position = player.global_position
