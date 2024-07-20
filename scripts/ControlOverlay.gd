extends Node2D

@onready var game_manager = $"/root/GameManager"
@onready var player = game_manager.player


@onready var left = $Left
@onready var right = $Right
@onready var up = $Up


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect player's choice_btn_pressed signal to own handler method
	player.choice_btn_pressed.connect(_on_choice_btn_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = player.global_position

func _on_choice_btn_pressed(btn):
	btn.scale.x = 2
	btn.scale.y = 2
	
