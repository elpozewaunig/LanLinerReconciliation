extends "res://scripts/PathAgent.gd"

@onready var overlay = $ChoiceOverlay

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
	next_switch_delta = 3.0
	
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
		next_switch_delta = rng.randf_range(0.5, 2.0)
		
		var choice = rng.randf()
		
		if choice <= 0.5:
			if current_lane > 0:
				current_lane -= 1
				switch_lane(current_lane)
				
		if choice > 0.5:
			if current_lane < lane_count - 1:
				current_lane += 1
				switch_lane(current_lane)


func _on_end_reached(time):
	emit_signal("enemy_end_reached", time)
	
func _on_dead_end_reached():
	sprite_container.hide()
	emit_signal("enemy_dead_end_reached")
