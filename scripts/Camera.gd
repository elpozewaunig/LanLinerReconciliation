extends Camera2D

@onready var vignette = $Vignette
@onready var game_over = $GameOver

@export var transition_speed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	vignette.scale.x = 1/zoom.x
	vignette.scale.y = 1/zoom.y
	
	game_over.scale.x = 1/zoom.x
	game_over.scale.y = 1/zoom.y
	
	# Gradually move camera back to relative zero on the x-axis
	if position.x > 0:
		position.x -= delta * transition_speed
		if position.x < 0:
			position.x = 0
			
	if position.x < 0:
		position.x += delta * transition_speed
		if position.x > 0:
			position.x = 0
			
	# Gradually move camera back to relative zero on the y-axis
	if position.y > 0:
		position.y -= delta * transition_speed
		if position.y < 0:
			position.y = 0
			
	if position.y < 0:
		position.y += delta * transition_speed
		if position.y > 0:
			position.y = 0

func transition_from_x(from_x):
	position.x = from_x - get_parent().global_position.x
