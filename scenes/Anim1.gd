extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$TrailAnim.play("anim1")
	$TrailAnim2.play("anim1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
