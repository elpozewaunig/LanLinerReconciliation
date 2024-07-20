extends Camera2D

@export var transition_speed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Gradually move camera back to relative zero on the x-axis
	if position.x > 0:
		print(position.x)
		position.x -= delta * transition_speed
		if position.x < 0:
			position.x = 0
			
	if position.x < 0:
		print(position.x)
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
	position.x = from_x - global_position.x
