extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scale.x > 1:
		scale.x -= delta
		scale.y -= delta
		if scale.x < 1:
			scale.x = 1
			scale.y = 1
