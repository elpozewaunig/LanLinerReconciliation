extends PathAgent

@onready var overlay = $ChoiceOverlay

@export_enum("Random Neighbour", "Best Neighbour") var strategy: int = 1

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
	
	# Switch to left or right lane when time elapsed exceeds next_switch_delta
	if time_elapsed > next_switch_delta:
		time_elapsed = 0
		
		if strategy == 0:
			switch_lane(get_random_neighbour())
			next_switch_delta = rng.randf_range(0.5, 2.0)
		elif strategy == 1:
			switch_lane(get_best_neighbour())
			next_switch_delta = 0.1

func get_random_neighbour():
	var choice = rng.randf()
		
	if choice <= 0.5:
		if current_lane > 0:
			return current_lane - 1
			
	if choice > 0.5:
		if current_lane < lane_count - 1:
			return current_lane + 1

# Simple AI for switching to best left or right lane
func get_best_neighbour():
	var current_sections = []
	# Iterate through all lanes
	for lane in alt_lanes:
		var lane_section_data = ai_preprocess_sections(lane)
		
		# Iterate through all pre-processed sections
		for section in lane_section_data:
			# Store section that the enemy can currently switch to
			if progress >= section["from"] and progress <= section["to"]:
				current_sections.append(section)
	
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

# Obtain section data from lane and pad it with default sections
# This allows the AI to easily compare its options
func ai_preprocess_sections(lane):
	var lane_section_data = []
	var path_length = lane.curve.get_baked_length()
	
	# Iterate through all sections, pad the section data with default sections
	for i in range(0, lane.tubele.size()):
		# Examining the first section
		if i == 0:
			# If the section doesn't start right at the start of the path
			var section_from = lane.tubele[0]["from"]
			if section_from != 0:
				lane_section_data.append({
					"from": 0,
					"to": section_from,
					"type": "default"
				})
		
		# Append the currently examined section
		lane_section_data.append(lane.tubele[i])
		
		# If not examining the last section
		if i != lane.tubele.size() - 1:
			# If there is space between sections, add a default section in it
			var section1_to = lane.tubele[i]["to"]
			var section2_from = lane.tubele[i+1]["from"]
			if section1_to + 1 != section2_from:
				lane_section_data.append({
					"from": section1_to,
					"to": section2_from,
					"type": "default"
				})
					
		# Examining the last section
		else:
			# If there is space between the last section and the path's end
			var section_to = lane.tubele[i]["to"]
			if section_to != path_length:
				# Add a default section to the space
				lane_section_data.append({
					"from": section_to,
					"to": path_length,
					"type": "default"
				})
	
	# If the current lane has no sections, fill it with a default section
	if lane_section_data.is_empty():
		lane_section_data.append({
			"from": 0,
			"to": path_length,
			"type": "default"
		})
	
	return lane_section_data

func _on_end_reached(time):
	emit_signal("enemy_end_reached", time)
	
func _on_dead_end_reached():
	sprite_container.hide()
	emit_signal("enemy_dead_end_reached")
