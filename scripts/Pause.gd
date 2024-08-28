extends Node2D

var pausable : bool = true

@onready var pause_screen = $PauseScreen
@onready var pause_button = $PauseButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if pausable:
		pause_button.show()
	else:
		pause_button.hide()
	
	# Pause the game when esc is pressed
	if Input.is_action_just_pressed("ui_pause"):
		toggle_pause()


func toggle_pause():
	if pausable:
		var scene_tree = get_tree()
		if scene_tree.paused:
			scene_tree.paused = false
			pause_screen.hide()
		else:
			scene_tree.paused = true
			pause_screen.show()
		
func _on_pause_button_clicked():
	toggle_pause()


func _on_player_end_reached(_time):
	pausable = false


func _on_player_dead_end_reached():
	pausable = false
