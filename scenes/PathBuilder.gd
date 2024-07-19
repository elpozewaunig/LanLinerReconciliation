extends Node2D


func createPath():
	var scene = load("res://scenes/visible_path.tscn")
	var path = scene.instantiate()
	var curve = Curve2D.new()
	curve.add_point(Vector2(0,100))
	curve.add_point(Vector2(100,200))

	return curve
