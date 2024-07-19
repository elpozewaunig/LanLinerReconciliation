extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var camera = $Camera2D
@onready var paths = game_manager.get_node("root")

var speed = 500
var zoom_fact = 0.001
var current_lane = 1

var lane_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get lanes
	for lane in paths.get_children():
		lane_count += 1
		
	# Set player to center lane, placing it on the lane's first path
	reparent(paths.get_child(lane_count/2).get_child(0))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Switch to left or right lane on input
	if Input.is_action_just_pressed("ui_left"):
		if current_lane > 0:
			current_lane -= 1
			switch_lane(current_lane)
			
	if Input.is_action_just_pressed("ui_right"):
		if current_lane < lane_count - 1:
			current_lane += 1
			switch_lane(current_lane)
	
	# Calculate progress along path according to speed
	var change = delta * speed * game_manager.tick_speed
	var change_ratio  = change / get_parent().curve.get_baked_length()
	
	# If progress would exceed current path, reparent to its child "SChild"
	if progress_ratio + change_ratio >= 1:
		var next_path = get_parent().get_node_or_null("SChild")
		
		# If there is another path to continue to, reparent
		if next_path:
			progress += change
			reparent(next_path)
			progress_ratio -= 1
		else:
			pass
	else:
		# Increase progress normally
		progress += change
		
	# Adjust camera zoom according to speed
	camera.zoom.x = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)
	camera.zoom.y = 1 / (speed * game_manager.tick_speed * zoom_fact + 1)

# Reparents the player to another lane
func switch_lane(index):
	# Lanes have identical hierarchy
	# Obtain the location of the player in the current hierarchy
	var tree_location = get_tree_location()
	
	# Switch to another sub-tree by changing the first index of the path
	tree_location[0] = index
	
	# Finally, reparent to the node definded by the new tree location
	reparent(get_child_from_tree_loc(paths, tree_location))


# Obtain an array of the indexes of the parents of this element 
func get_tree_location():
	var current = self.get_parent()
	var indexes = []
	# Seek parents in hierarchy until root of path lanes is reached
	while not current.name == "root":
		indexes.append(current.get_index())
		current = current.get_parent()
	indexes.reverse()
	return indexes

# Returns a child in a scene by following a list of the indexes of its parents
func get_child_from_tree_loc(start, indexes):
	var current = start
	for i in indexes:
		current = current.get_child(i)
	return current
