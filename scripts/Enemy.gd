extends PathAgent

@onready var overlay = $ChoiceOverlay

@export_enum("Random Neighbour", "Best Neighbour", "Move Towards Best Lane", "Best Lane") var strategy: int = 3

var rng = RandomNumberGenerator.new()
var next_switch_delta = 0
var time_elapsed = 0

var overlay_shown_timer = 0

signal force_next_choice(branch)
signal enemy_end_reached(time)
signal enemy_dead_end_reached()

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	next_switch_delta = 0
	
	# Connect player's force_next_choice signal to own handler method
	var player = game_manager.player
	player.force_next_choice.connect(_on_force_next_choice)
	
	enemy_end_reached.connect(player._on_enemy_end_reached)
	enemy_dead_end_reached.connect(player._on_enemy_dead_end_reached)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle speed settings and path interactions in super class
	super._process(delta)
	
	time_elapsed += delta
	
	# If progress nears the current path's end and the enemy is ahead of the player
	if progress_ratio > 0.75 and branch_choice == null and total_progress > game_manager.player.total_progress:
		# Set the branch to proceed to randomly
		# Get keys
		var branches_keys = branches.keys()
		# Make sure that only candidates with no dead end are chosen
		var candidate_branch_names = []
		for key in branches_keys:
			if !branches[key].isDeadEnd:
				candidate_branch_names.append(branches[key].name)
		
		# Get random index of new candidate branches array
		var random_index = rng.randi_range(0, candidate_branch_names.size() - 1)
		
		# If a branch to continue to (that is not a dead end) exists
		if candidate_branch_names.size() >= 1:
			# Choose the branch corresponding to the random index
			branch_choice = candidate_branch_names[random_index]
			emit_signal("force_next_choice", branch_choice)
			
			# Reset all choice overlay options to be hidden
			var choice_btn
			overlay.up.hide()
			overlay.left.hide()
			overlay.right.hide()
			
			# Show button according to made choice
			if(branch_choice == "SChild"):
				choice_btn = overlay.up
			elif(branch_choice == "LChild"):
				choice_btn = overlay.left
			elif(branch_choice == "RChild"):
				choice_btn = overlay.right
			choice_btn.show()
			
			# Show overlay and reset overlay timer
			overlay.appearing = true
			overlay_shown_timer = 0
	
	# When the overlay is fully visible
	if overlay.modulate.a >= 1:
				overlay_shown_timer += delta
				# Wait until timer exceeds value to make it disappear again
				if overlay_shown_timer > 1:
					overlay.appearing = false
	
	# Handle movement and advancing to the next path in super class
	super.apply_progress(delta)
	
	# Switch lanes when the elapsed time exceeds next_switch_delta
	if time_elapsed > next_switch_delta:
		time_elapsed = 0
		
		if strategy == 0:
			switch_lane(get_random_neighbour())
			next_switch_delta = rng.randf_range(0.5, 2.0)
		elif strategy == 1:
			switch_lane(get_best_neighbour())
			next_switch_delta = 0.05
		elif strategy == 2:
			switch_lane(get_best_lane(false))
			next_switch_delta = 0.05
		elif strategy == 3:
			switch_lane(get_best_lane(true))
			next_switch_delta = 0

# Randomly returns left or right lane index
func get_random_neighbour():
	var choice = rng.randf()
		
	if choice <= 0.5:
		if current_lane > 0:
			return current_lane - 1
			
	if choice > 0.5:
		if current_lane < lane_count - 1:
			return current_lane + 1

# Returns the best lane to move to
# If teleport is on, it will immediately return the best lane
# Otherwise, it will return the next closer lane to the best lane
func get_best_lane(teleport):
	var current_sections = get_sections_at(progress)
	
	# Find the lane that currently provides the best speed
	var target_lane = find_best_section(current_sections)

	# Find the end of the current section ending soonest
	var next_dist = get_parent().curve.get_baked_length()
	for section in current_sections:
		if section["to"] < next_dist:
			next_dist = section["to"]
	
	# Get the sections after the first end of a current section
	var sections_at_point = get_sections_at(next_dist)
	# Find the best lane at this future point
	var next_target_lane = find_best_section(sections_at_point)
	
	var target_type = current_sections[target_lane]["type"]
	var pre_next_type = current_sections[next_target_lane]["type"]
	
	# If changing to this next lane offers the same speed as the target lane
	if speeds[pre_next_type]["value"] == speeds[target_type]["value"]:
		# Switch to it ahead of time
		target_lane = next_target_lane

	# If teleport is enabled, jump to the target lane
	if teleport:
		return target_lane
	
	# Else, only move one lane closer to the target lane
	if target_lane < current_lane:
		return current_lane - 1
	elif target_lane > current_lane:
		return current_lane + 1
	else:
		return current_lane

# Returns index of section with best speed given an array with sections
# Prefers sections closer to the current_lane
func find_best_section(sections):
	var target_lane = current_lane
	var examine_lane = 0
	var best_speed = 0
	
	# Iterate through all currently available sections
	for section in sections:
		var examine_section = sections[examine_lane]
		var current_speed = speeds[examine_section["type"]]["value"]
		
		# If the section provides better speed than the ones examined before
		if current_speed > best_speed:
			best_speed = current_speed
			target_lane = examine_lane
		# If the section is the same as the best option but is closer to the current lane
		elif current_speed == best_speed and abs(current_lane - examine_lane) < abs(current_lane - target_lane):
			target_lane = examine_lane
		
		examine_lane += 1
		
	return target_lane

# Returns index of best neighbouring lane
func get_best_neighbour():
	var current_sections = get_sections_at(progress)
	
	var origin_lane_int = current_lane
	var left_lane_int = origin_lane_int
	var right_lane_int = origin_lane_int
	
	# If the origin isn't already the leftmost lane
	if origin_lane_int > 0:
		left_lane_int -= 1
	# If the origin isn't already the rightmost lane
	if origin_lane_int < alt_lanes.size()-1:
		right_lane_int += 1
		
	var options = [origin_lane_int, left_lane_int, right_lane_int]
	
	var current_best_speed = 0
	var choice = origin_lane_int
	
	# Iterate through all options, examine their speed
	for option in options:
		var section_type = current_sections[option]["type"]
		var section_speed = speeds[section_type]["value"]
		
		# If it has higher speed than the ones before, mark it as next best
		if section_speed > current_best_speed:
			current_best_speed = section_speed
			choice = option
	
	return choice

# Returns all sections available at a given position, based on data pre-processed by PathAgent
func get_sections_at(at_pos):
	var current_sections = []
		
	# Iterate through all pre-processed sections
	for lane_section_data in lanes_section_data:
		for section in lane_section_data:
			# Store section that the enemy can currently switch to
			if at_pos >= section["from"] and at_pos < section["to"]:
				current_sections.append(section)
	
	return current_sections

func _on_end_reached(time):
	emit_signal("enemy_end_reached", time)
	
func _on_dead_end_reached():
	sprite_container.hide()
	emit_signal("enemy_dead_end_reached")
