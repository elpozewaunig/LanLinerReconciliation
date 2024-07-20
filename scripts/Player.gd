extends "res://scripts/PathAgent.gd"

@onready var camera = $Camera2D

var zoom_fact = 0.001

signal force_next_choice(branch)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Handle speed settings and path interactions in super class
	super._ready()
	
	# Connect enemy's force_next_choice signal to own handler method
	var enemy = game_manager.enemy
	enemy.force_next_choice.connect(_on_force_next_choice)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	
	var vignette = camera.get_node("Vignette")
	
	# If progress nears the current path's end, slow down
	if progress_ratio > 0.75 and branch_choice == null and total_progress >= game_manager.enemy.total_progress and branches.has("SChild"):
		# Show vignette
		vignette.show()
		vignette.modulate.a += delta * 2
		if vignette.modulate.a > 1:
			vignette.modulate.a = 1
		
		game_manager.tick_speed -= delta
		if game_manager.tick_speed < 0.3:
			game_manager.tick_speed = 0.3
		
		# Set the branch to proceed to based on input
		if Input.is_action_just_pressed("ui_up") and branches.has("SChild"):
			branch_choice = branches["SChild"]
			emit_signal("force_next_choice", branch_choice)
		elif Input.is_action_just_pressed("ui_left") and branches.has("LChild"):
			branch_choice = branches["LChild"]
			emit_signal("force_next_choice", branch_choice)
		elif Input.is_action_just_pressed("ui_right") and branches.has("RChild"):
			branch_choice = branches["RChild"]
			emit_signal("force_next_choice", branch_choice)
		
	# Speed back up		
	else:
		# Hide vignette 
		vignette.modulate.a -= delta * 2
		if vignette.modulate.a <= 0:
			vignette.modulate.a = 0
			camera.get_node("Vignette").hide()
		
		game_manager.tick_speed += delta
		if  game_manager.tick_speed > 1:
			game_manager.tick_speed = 1
		
	# Handle movement and advancing to the next path in super class
	super.apply_progress(delta)
		
	# Adjust camera zoom according to speed
	camera.zoom.x = 1 / (speed * zoom_fact + 0.5) * game_manager.tick_speed
	camera.zoom.y = 1 / (speed * zoom_fact + 0.5) * game_manager.tick_speed
	
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
			
