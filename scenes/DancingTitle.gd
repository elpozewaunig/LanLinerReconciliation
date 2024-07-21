extends Label

var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotation_degrees < 3 and direction == 1:
		rotation_degrees += delta * 10
		if rotation_degrees >= 3:
			direction = -1
			
	if rotation_degrees > -3 and direction == -1:
		rotation_degrees -= delta * 10
		if rotation_degrees <= -3:
			direction = 1
