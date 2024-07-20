extends AnimatedSprite2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
var timeElapsed = 0 
func _process(delta) :
	timeElapsed+=delta
	if(timeElapsed>0.01):
		frame = rng.randi_range(0, 4)
		timeElapsed = 0
