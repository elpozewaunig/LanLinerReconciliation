extends Label

@export var max_rotation_deg = 3
@export var rotation_speed = 10
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotation_degrees < max_rotation_deg and direction == 1:
		rotation_degrees += delta * rotation_speed
		if rotation_degrees >= max_rotation_deg:
			direction = -1
			
	if rotation_degrees > -1 * max_rotation_deg and direction == -1:
		rotation_degrees -= delta * rotation_speed
		if rotation_degrees <= -1 * max_rotation_deg:
			direction = 1
