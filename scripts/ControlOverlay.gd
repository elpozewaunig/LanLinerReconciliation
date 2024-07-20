extends Node2D

@onready var game_manager = $"/root/GameManager"
@onready var player = game_manager.player

@onready var left = $Left
@onready var right = $Right
@onready var up = $Up

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_choice_btn_pressed(btn):
	btn.scale.x = 2
	btn.scale.y = 2
	
