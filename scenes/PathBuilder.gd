extends Node2D

func createPath():
	var scene = load("res://scenes/visible_path.tscn")
	var path = scene.instantiate()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(0,100))
	path.curve.add_point(Vector2(100,200))

	return path
