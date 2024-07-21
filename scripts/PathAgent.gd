extends PathFollow2D

@onready var game_manager = $"/root/GameManager"
@onready var paths = game_manager.get_node("root")
@onready var sprite_container = $Sprites

@export var default_speed : int = 500
@export var slow_speed : int = 200
@export var fast_speed : int = 1000
@export var extra_slow_speed : int = 100
@export var extra_fast_speed : int = 2000
var speed = 0

var total_progress = 0

var lane_count = 0
var current_lane = 0

var current_section = ""

var branches = {}
var branch_choice = null
var branch_passed_count = 0

var end = false
var finish_time = 0
var dead_end = false

signal delete_branch
signal no_choice_made
signal end_reached(time)
signal dead_end_reached


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get lanes
	for lane in paths.get_children():
		lane_count += 1
		
	# Set agent to center lane, placing it on the lane's first path
	current_lane = lane_count/2
	reparent(paths.get_child(current_lane).get_node("SChild"))
	update_available_branches()
	no_choice_made.connect(_on_no_choice_made)
	dead_end_reached.connect(_on_dead_end_reached)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Increase a timer, until the end is reached
	if !end:
		finish_time += delta
	
	# Obtain the speed information of the current path
	var current_path_data = get_parent().tubele
	var is_in_section = false
	for section in current_path_data:
		# If the agent is in a specific section, change its speed accordingly
		if progress >= section[0] and progress <= section[1]:
			is_in_section = true
			current_section = section[2]
			
			if current_section == "speed":
				if speed < fast_speed:
					speed += delta * game_manager.tick_speed * 500
					if speed > fast_speed:
						speed = fast_speed
					
			if current_section == "slow":
				if speed > slow_speed:
					speed -= delta * game_manager.tick_speed * 500
					if speed < slow_speed:
						speed = slow_speed
					
			if current_section == "extraspeed":
				if speed < extra_fast_speed:
					speed += delta * game_manager.tick_speed * 10000
					if speed > extra_fast_speed:
						speed = extra_fast_speed
					
			if current_section == "extraslow":
				if speed > extra_slow_speed:
					speed -= delta * game_manager.tick_speed * 5000
					if speed < extra_slow_speed:
						speed = extra_slow_speed
	
	# If the agent is not in a section, accelerate/decelerate to regular speed
	if !is_in_section:
		
		current_section = "default"
		
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
			notify_abandoned_branches()
			branch_passed_count += 1
			progress_ratio -= 1
			if get_parent().isDeadEnd:
				dead_end = true
		
		# If the agent hasn't made a choice, but there is a straight path
		elif branches.has("SChild"):
			progress += change
			emit_signal("no_choice_made")
			reparent(branches["SChild"])
			notify_abandoned_branches()
			branch_passed_count += 1
			progress_ratio -= 1
			if get_parent().isDeadEnd:
				dead_end = true
			
		# There are no further branches
		else:
			if !dead_end and !end:
				emit_signal("end_reached", finish_time)
				end = true
				
			elif dead_end and !end:
				emit_signal("dead_end_reached")
				end = true
		
		# Reset choice, game can resume normally
		branch_choice = null
		update_available_branches()
		
	else:
		# Increase progress normally
		progress += change
	
	# Find the next point that is ahead of the player in the current path
	var points = get_parent().curve.get_baked_points()
	var next_point = null
	var progress_of_point = 0
	for i in range(1, points.size()):
		# Sum up distances between adjacent points to get the corresponding progress value
		progress_of_point += points[i-1].distance_to(points[i])
		# If the point corresponds to a bigger progress value than the agent's position
		if progress <= progress_of_point:
			next_point = points[i]
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

# Connect all unchosen branches to delete_branch signal, then emit
func notify_abandoned_branches():
	var tree_location = get_tree_location()
	
	# Iterate through all lanes
	for lane_index in range(lane_count):
		tree_location[0] = lane_index
		
		# Get all the branches that could have been chosen on this layer
		var branch_layer = get_child_from_tree_loc(tree_location).get_parent()
		for branch in branch_layer.get_children():
			# There may be other objects other than paths in the hierarchy
			# Make sure we only connect the signal to paths
			if branch is Path2D:
				# If a branch doesn't match the branch that was chosen
				if branch.name != get_parent().name:
					# Connect signal delete_branch to _on_delete_branch method of unchosen branch
					delete_branch.connect(branch._on_delete_branch)
	
	emit_signal("delete_branch")

# Reparents the player to another lane
func switch_lane(index):
	# Lanes have identical hierarchy
	# Obtain the location of the player in the current hierarchy
	var tree_location = get_tree_location()
	
	# Switch to another sub-tree by changing the first index of the path
	tree_location[0] = index
	
	# Finally, reparent to the node definded by the new tree location
	reparent(get_child_from_tree_loc(tree_location), false)
	
	# Update available branches for the next decision
	update_available_branches()

# Obtain an array of the indexes of the parents of this element 
func get_tree_location():
	var current = get_parent()
	var indexes = []
	# Seek parents in hierarchy until root of path lanes is reached
	while not current.name == "root":
		indexes.append(current.get_index())
		current = current.get_parent()
	indexes.reverse()
	return indexes

# Returns a child in a scene (starting at paths) by following a list of the indexes of its parents
func get_child_from_tree_loc(indexes):
	var current = paths
	for i in indexes:
		current = current.get_child(i)
	return current

# Sets the agents own choice, forcing it to move to the specified branch
func _on_force_next_choice(forced_branch):
	# Since we aren't necessarily immediately behind the other player, remember the choice
	game_manager.branch_choices.append(forced_branch.name)
	# Based on the branches we have already passed, get the next forced branch
	var next_branch_name = game_manager.branch_choices[branch_passed_count]
	for branch_name in branches:
		if branch_name == next_branch_name:
			branch_choice = branches[next_branch_name]

func _on_no_choice_made():
	pass
	
func _on_dead_end_reached():
	pass
