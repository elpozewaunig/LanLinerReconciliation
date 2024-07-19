extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var camera = $Camera2D

var speed = 100
var zoom_fact = 0.001
var current_lane = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# The player is the child of the current path
	# The parent of the current path therefore contains other valid paths
	var current_path_layer = get_parent().get_parent()
	var next_path_layer = get_parent()
	
	# Get all valid path indexes on the current layer
	var parallel_paths = []
	for child in current_path_layer.get_children():
		if child is Path2D:
			parallel_paths.append(child.get_index())
	
	# Switch to left or right sibling of current path on input
	if Input.is_action_just_pressed("ui_left"):
		if current_lane > 0:
			current_lane -= 1
			reparent(current_path_layer.get_child(parallel_paths[current_lane]))
	if Input.is_action_just_pressed("ui_right"):
		if current_lane < parallel_paths.size() - 1:
			current_lane += 1
			reparent(current_path_layer.get_child(parallel_paths[current_lane]))
	
	# Calculate progress along path according to speed
	var change = delta * speed * game_manager.tick_speed
	var change_ratio  = change / get_parent().curve.get_baked_length()
	
	# If progress would exceed current path, reparent to its child
	if progress_ratio + change_ratio >= 1:
		# Get all valid path indexes on the next layer
		var next_paths = []
		for child in next_path_layer.get_children():
			if child is Path2D:
				next_paths.append(child.get_index())
				
		# If there is another path to continue to, reparent
		if next_paths.size() > 0:
			progress += change
			var next = get_parent().get_child(next_paths[next_paths.size()/2])
			reparent(next)
			progress_ratio -= 1
		else:
			pass
	else:
		# Increase progress normally
		progress += change
		
	# Adjust camera zoom according to speed
	camera.zoom.x = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
	camera.zoom.y = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
		
	
	
	
