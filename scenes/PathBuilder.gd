extends Node2D

var pl = 500
var rng = RandomNumberGenerator.new()

func createPath():
	var root = getInstance()
	root.name = "root"
	root.curve.add_point(Vector2(0,-pl))
	root.add_child(rec(5, Vector2(0,-pl)))
	return root

func rec(recursionDepth: int, origin: Vector2):
	var path = getInstance()
	path.name = "LChild" 
	
	var rdmNum = rng.randi_range(-1,1)
	
	path.position = Vector2(origin.x,origin.y)
	path.curve.add_point(Vector2(rdmNum*pl,-pl))
	var newOrigin = Vector2(origin.x+(rdmNum*pl), origin.y-pl)
	if(recursionDepth!=1):
		path.add_child(rec(recursionDepth-1,newOrigin))
	return path

func getInstance() -> Path2D:
	var scene = preload("res://scenes/visible_path.tscn") #preload geht aber load nit :huh:
	var path = scene.instantiate()
	path.curve = Curve2D.new()
	return path
	
