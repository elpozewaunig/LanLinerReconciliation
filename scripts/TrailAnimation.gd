extends AnimatedSprite2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
var c = 0
func _process(delta):
	
	if(c==10):
		frame = rng.randi_range(0, 4)
		c=0
	c+=1
