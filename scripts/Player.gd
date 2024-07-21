extends "res://scripts/PathAgent.gd"

@onready var camera = $Camera2D
@onready var sound = $Sounds
@onready var controls = $ControlOverlay
@onready var game_over_screen = camera.get_node("GameOver")
@onready var vignette = camera.get_node("Vignette")
var enemy

var zoom_fact = 0.001
var lane_lock = false
var game_over = false

var last_section = ""

signal force_next_choice(branch)
signal choice_btn_pressed(btn)
signal enemy_end_reached(time)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Handle speed settings and path interactions in super class
	super._ready()
	
	# Connect enemy's force_next_choice signal to own handler method
	enemy = game_manager.enemy
	enemy.force_next_choice.connect(_on_force_next_choice)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	
	if last_section != current_section:
		last_section = current_section
		
		if current_section == "speed":
			sound.speed.play()
		if current_section == "slow":
			sound.slow.play()
		if current_section == "extraspeed":
			sound.extra_speed.play()
		if current_section == "extraslow":
			sound.extra_slow.play()
	
	# If progress nears the current path's end, slow down
	if progress_ratio > 0.75 and branch_choice == null and total_progress >= game_manager.enemy.total_progress and branches.has("SChild"):
		# From now on switching lanes is prohibited, until a choice is made
		lane_lock = true
		
		# There is a brief period where no choices may be made to prevent accidental choices
		var allow_choice = false
		
		# Show vignette
		vignette.show()
		vignette.modulate.a += delta * 2
		if vignette.modulate.a > 1:
			vignette.modulate.a = 1
			
		# Show available choices
		controls.show()
		controls.modulate.a += delta * 2
		if controls.modulate.a > 1:
			controls.modulate.a = 1
			
		if branches.has("SChild"):
			controls.up.show()
		else:
			controls.up.hide()
		if branches.has("LChild"):
			controls.left.show()
		else:
			controls.left.hide()
		if branches.has("RChild"):
			controls.right.show()
		else:
			controls.right.hide()
		
		game_manager.tick_speed -= delta * 2
		if game_manager.tick_speed < 0.3:
			game_manager.tick_speed = 0.3
			# When player has fully slowed down, allow choice
			allow_choice = true
		
		# Set the branch to proceed to based on input
		if allow_choice:
			if Input.is_action_just_pressed("ui_up") and branches.has("SChild"):
				branch_choice = branches["SChild"]
				emit_signal("force_next_choice", branch_choice)
				emit_signal("choice_btn_pressed", controls.up)
			elif Input.is_action_just_pressed("ui_left") and branches.has("LChild"):
				branch_choice = branches["LChild"]
				emit_signal("force_next_choice", branch_choice)
				emit_signal("choice_btn_pressed", controls.left)
			elif Input.is_action_just_pressed("ui_right") and branches.has("RChild"):
				branch_choice = branches["RChild"]
				emit_signal("force_next_choice", branch_choice)
				emit_signal("choice_btn_pressed", controls.right)
		
	# Speed back up
	else:
		lane_lock = false
		
		# Hide vignette 
		vignette.modulate.a -= delta * 2
		if vignette.modulate.a <= 0:
			vignette.modulate.a = 0
			camera.get_node("Vignette").hide()
			
		# Hide control options
		controls.modulate.a -= delta * 3
		if controls.modulate.a <= 0:
			controls.modulate.a = 0
			controls.hide()
		
		game_manager.tick_speed += delta
		if  game_manager.tick_speed > 1:
			game_manager.tick_speed = 1
		
	# Handle movement and advancing to the next path in super class
	super.apply_progress(delta)
	
	# Adjust camera zoom according to speed
	camera.zoom.x = 1 / (speed * zoom_fact + 0.5) * game_manager.tick_speed
	camera.zoom.y = 1 / (speed * zoom_fact + 0.5) * game_manager.tick_speed
	
	# Switch to left or right lane on input
	if Input.is_action_just_pressed("ui_left") and !lane_lock:
		if current_lane > 0:
			current_lane -= 1
			var last_global_x = camera.global_position.x
			switch_lane(current_lane)
			camera.transition_from_x(last_global_x)
			sound.lane_switch_left.play()
			
	if Input.is_action_just_pressed("ui_right") and !lane_lock:
		if current_lane < lane_count - 1:
			current_lane += 1
			var last_global_x = camera.global_position.x
			switch_lane(current_lane)
			camera.transition_from_x(last_global_x)
			sound.lane_switch_right.play()
			
	if game_over:
		# Show game over screen
		game_over_screen.show()
		game_over_screen.modulate.a += delta * 2
		if game_over_screen.modulate.a > 1:
			game_over_screen.modulate.a = 1
			
func _on_no_choice_made():
	emit_signal("force_next_choice", branches["SChild"])
	emit_signal("choice_btn_pressed", controls.up)

func _on_end_reached(time):
	sound.win.play()

func _on_enemy_end_reached(time):
	emit_signal("enemy_end_reached", time)
	
func _on_dead_end_reached():
	game_over = true
	game_over_screen.modulate.a = 0
	sound.lose.play()
