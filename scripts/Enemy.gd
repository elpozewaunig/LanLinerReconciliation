extends "res://scripts/PathAgent.gd"

var rng = RandomNumberGenerator.new()
var next_switch_delta = 0
var time_elapsed = 0

signal force_next_choice(branch)
signal enemy_end_reached(time)

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	next_switch_delta = 3.0
	
	# Connect player's force_next_choice signal to own handler method
	var player = game_manager.player
	player.force_next_choice.connect(_on_force_next_choice)
	
	enemy_end_reached.connect(player._on_enemy_end_reached)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle speed settings and path interactions in super class
	super._process(delta)
	
	time_elapsed += delta
	
	# If progress nears the current path's end, slow down
	if progress_ratio > 0.75 and branch_choice == null and total_progress > game_manager.player.total_progress:
	
		# Set the branch to proceed to randomly
		# Get keys, then get random index within the key array
		var branches_keys = branches.keys()
		var random_index = rng.randi_range(0, branches.size() - 1)
		
		# If a branch to continue to exists
		if branches.size() >= 1:
			# Choose the branch corresponding to the random index
			branch_choice = branches[branches_keys[random_index]]
			emit_signal("force_next_choice", branch_choice)

	# Handle movement and advancing to the next path in super class
	super.apply_progress(delta)
	
	# Switch to left or right lane when time elapsed exceeds next_switch_delta
	if time_elapsed > next_switch_delta:
		time_elapsed = 0
		next_switch_delta = rng.randf_range(0.5, 2.0)
		
		var choice = rng.randf()
		
		if choice <= 0.5 and branch_choice == null:
			if current_lane > 0:
				current_lane -= 1
				switch_lane(current_lane)
				
		if choice > 0.5 and branch_choice == null:
			if current_lane < lane_count - 1:
				current_lane += 1
				switch_lane(current_lane)


func _on_end_reached(time):
	emit_signal("enemy_end_reached", time)
