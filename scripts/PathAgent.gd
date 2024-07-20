extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var paths = game_manager.get_node("root")
@onready var sprite_container = $Sprites

@export var default_speed : int = 500
@export var slow_speed : int = 200
@export var fast_speed : int = 1000
var speed = 0

var total_progress = 0

var lane_count = 0
var current_lane = 0

var branches = {}
var branch_choice = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get lanes
	for lane in paths.get_children():
		lane_count += 1
		
	# Set agent to center lane, placing it on the lane's first path
	current_lane = lane_count/2
	reparent(paths.get_child(current_lane).get_node("SChild"))
	update_available_branches()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Obtain the speed information of the current path
	var current_path_data = get_parent().tubele
	var is_in_section = false
	for section in current_path_data:
		# If the agent is in a specific section, change its speed accordingly
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
	
	# If the agent is not in a section, accelerate/decelerate to regular speed
	if !is_in_section:
		
		if speed < default_speed:
			speed += delta * 500
			if speed > default_speed:
				speed = default_speed
				
		if speed > default_speed:
			speed -= delta * 500
			if speed < default_speed:
				speed = default_speed
	
# Move PathFollow2D along Path2D, reparent to child if the end is reached
func apply_progress(delta):
	# Calculate progress along path according to speed
	var change = delta * speed * game_manager.tick_speed
	var change_ratio  = change / get_parent().curve.get_baked_length()
	total_progress += change
	
	# If progress would exceed current path, reparent to the chosen branch
	if progress_ratio + change_ratio >= 1:
		# If the agent made a choice
		if branch_choice != null:
			progress += change
			reparent(branch_choice)
			progress_ratio -= 1
		
		# If the agent hasn't made a choice, but there is a straight path
		elif branches.has("SChild"):
			progress += change
			reparent(branches["SChild"])
			progress_ratio -= 1
			
		# There are no further branches
		else:
			pass
		
		# Reset choice, game can resume normally
		branch_choice = null
		update_available_branches()
		
	else:
		# Increase progress normally
		progress += change
	
	# Find the next point that is ahead of the player in the current path
	var points = get_parent().curve.get_baked_points()
	var next_point = null
	for point in points:
		if point.y <= position.y:
			next_point = point
			break
	
	# If there is a point to rotate towards
	if next_point != null:
		# Get the global position of the next point
		var global_point = get_parent().global_position + next_point
		# Adjust rotation of sprites to turn towards next point
		sprite_container.look_at(global_point)
		# Make the sprite face upwards
		sprite_container.rotation_degrees += 90
	
	
# Get all currently available branches from the current path
func update_available_branches():
		var branch_layer = get_parent()
		branches.clear()
		for branch in branch_layer.get_children():
			if branch is Path2D:
				branches[branch.name] = branch

# Reparents the player to another lane
func switch_lane(index):
	# Lanes have identical hierarchy
	# Obtain the location of the player in the current hierarchy
	var tree_location = get_tree_location()
	
	# Switch to another sub-tree by changing the first index of the path
	tree_location[0] = index
	
	# Finally, reparent to the node definded by the new tree location
	reparent(get_child_from_tree_loc(paths, tree_location), false)
	
	# Update available branches for the next decision
	update_available_branches()

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

# Sets the agents own choice, forcing it to move to the specified branch
func _on_force_next_choice(forced_branch):
	for branch_name in branches:
		if branch_name == forced_branch.name:
			branch_choice = branches[branch_name]
