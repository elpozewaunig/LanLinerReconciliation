extends "res://scripts/PathAgent.gd"

var rng = RandomNumberGenerator.new()
var next_switch_delta = 0
var time_elapsed = 0

signal force_next_choice(branch)

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	next_switch_delta = 3.0
	
	# Connect player's force_next_choice signal to own handler method
	var player = game_manager.player
	player.force_next_choice.connect(_on_force_next_choice)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle speed settings and path interactions in super class
	super._process(delta)
	
	time_elapsed += delta
	
	# If progress nears the current path's end, slow down
	if progress_ratio > 0.75 and branch_choice == null and total_progress > game_manager.player.total_progress:
	
		# Set the branch to proceed to based on a set order [TODO: better decisions]
		if branches.has("SChild"):
			branch_choice = branches["SChild"]
			emit_signal("force_next_choice", branch_choice)
		elif branches.has("LChild"):
			branch_choice = branches["LChild"]
			emit_signal("force_next_choice", branch_choice)
		elif branches.has("RChild"):
			branch_choice = branches["RChild"]
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
