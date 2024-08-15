extends Sprite2D

var pausable : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Pause the game when esc is pressed
	if Input.is_action_just_pressed("ui_cancel") and pausable:
		var scene_tree = get_tree()
		if scene_tree.paused:
			scene_tree.paused = false
			hide()
		else:
			scene_tree.paused = true
			show()


func _on_player_end_reached(_time):
	pausable = false


func _on_player_dead_end_reached():
	pausable = false
