extends Label

@export var decimal_places = 3

var end_reached = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if end_reached:
		modulate.a += delta
		if modulate.a > 1:
			modulate.a = 1


func _on_end_reached(time):
	end_reached = true
	position.y -= 300
	modulate.a = 0
	var time_rounded = round(time * pow(10, decimal_places)) / pow(10, decimal_places)
	text = str(time_rounded)
	show()
