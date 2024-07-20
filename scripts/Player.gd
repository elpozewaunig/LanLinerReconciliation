extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var camera = $Camera2D
@onready var paths = game_manager.get_node("root")

@export var default_speed : int = 500
@export var slow_speed : int = 300
@export var fast_speed : int = 700
var speed = 0

var zoom_fact = 0.001
var tick_speed = 1

var lane_count = 0
var current_lane = 0

var branch_choice = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get lanes
	for lane in paths.get_children():
		lane_count += 1
		
	# Set player to center lane, placing it on the lane's first path
	current_lane = lane_count/2
	reparent(paths.get_child(current_lane).get_node("SChild"))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Obtain the speed information of the current path
	var current_path_data = get_parent().tubele
	var is_in_section = false
	for section in current_path_data:
		# If the player is in a specific section, change its speed accordingly
		if progress >= section[0] and progress <= section[1]:
			is_in_section = true
			
			if section[2] == "speed":
				speed += delta * 500
				if speed > fast_speed:
					speed = fast_speed
					
			if section[2] == "slow":
				speed -= delta * 500
				if speed < slow_speed:
					speed = slow_speed
				
	if !is_in_section:
		
		if speed < default_speed:
			speed += delta * 500
			if speed > default_speed:
				speed = default_speed
				
		if speed > default_speed:
			speed -= delta * 500
			if speed < default_speed:
				speed = default_speed
				
	else:
		is_in_section = false
	
	# Calculate progress along path according to speed
	var change = delta * speed * tick_speed
	var change_ratio  = change / get_parent().curve.get_baked_length()
	
	var branches = {}
	
	# If progress nears the current path's end, slow down
	if progress_ratio > 0.75 and branch_choice == null:
		tick_speed -= delta
		if tick_speed < 0.3:
			tick_speed = 0.3
		
		# Get all currently available branches
		var branch_layer = get_parent()
		for branch in branch_layer.get_children():
			if branch is Path2D:
				branches[branch.name] = branch
		
		# Set the branch to proceed to based on input
		if Input.is_action_just_pressed("ui_up") and branches.has("SChild"):
			branch_choice = branches["SChild"]
		elif Input.is_action_just_pressed("ui_left") and branches.has("LChild"):
			branch_choice = branches["LChild"]
		elif Input.is_action_just_pressed("ui_right") and branches.has("RChild"):
			branch_choice = branches["RChild"]
		
	# Speed back up		
	else:
		tick_speed += delta
		if  tick_speed > 1:
			tick_speed = 1
		
	
	# If progress would exceed current path, reparent to the chosen branch
	if progress_ratio + change_ratio >= 1:
		# If the player made a choice
		if branch_choice != null:
			progress += change
			reparent(branch_choice)
			progress_ratio -= 1
		
		# If the player hasn't made a choice, but there is a straight path
		elif branches.size() > 0:
			progress += change
			reparent(branches["SChild"])
			progress_ratio -= 1
			
		# There are no further branches
		else:
			pass
		
		# Reset choice, game can resume normally
		branch_choice = null
		
	else:
		# Increase progress normally
		progress += change
		
	# Adjust camera zoom according to speed
	camera.zoom.x = 1 / (speed * zoom_fact + 0.5) * tick_speed
	camera.zoom.y = 1 / (speed * zoom_fact + 0.5) * tick_speed
	
	# Switch to left or right lane on input
	if Input.is_action_just_pressed("ui_left") and branch_choice == null:
		if current_lane > 0:
			current_lane -= 1
			var last_global_x = camera.global_position.x
			switch_lane(current_lane)
			camera.transition_from_x(last_global_x)
			
	if Input.is_action_just_pressed("ui_right") and branch_choice == null:
		if current_lane < lane_count - 1:
			current_lane += 1
			var last_global_x = camera.global_position.x
			switch_lane(current_lane)
			camera.transition_from_x(last_global_x)


# Reparents the player to another lane
func switch_lane(index):
	# Lanes have identical hierarchy
	# Obtain the location of the player in the current hierarchy
	var tree_location = get_tree_location()
	
	# Switch to another sub-tree by changing the first index of the path
	tree_location[0] = index
	
	# Finally, reparent to the node definded by the new tree location
	reparent(get_child_from_tree_loc(paths, tree_location), false)


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
