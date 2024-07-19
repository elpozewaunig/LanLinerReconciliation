extends Node2D


var pl = 250 # how long is a path-line in px
var gap = 80 # how many px gap between the duplis 
var ec = 3 # how many path elements
var lpp = 2 # how many lines per path? (additional to asfo)
var asfo = 2 # how many lines after a split to fade out into a normal path
var rng = RandomNumberGenerator.new()

func createPath():
	var root = Node2D.new()
	var lane = Node2D.new()
	var neuepath = rec(ec, Vector2(0,0),"nofade")
	lane.add_child(neuepath)
	lane.name = "lane0"
	root.add_child(lane)
	for i in 4:
		var dupli = lane.duplicate()
		dupli.position = Vector2(dupli.position.x-(gap*(i+1)), dupli.position.y)
		dupli.name = "lane"+str(i+1)
		root.add_child(dupli)
	
	root.name = "root"
	return root

func rec(recursionDepth: int, origin: Vector2, name:String):
	var path = getInstance()
	

	path.position = Vector2(origin.x,origin.y)
	path.curve.add_point(Vector2(0,0))
	var prevlr = 0
	
	var fadedist = asfo*pl
	fadedist = asfo*pl
	if(name=="LChild"):
		for i in asfo:
			path.curve.add_point(Vector2(-(i+1)*pl,-(pl*(i+1))))	
		prevlr += -1*asfo
	elif(name=="RChild"):
		for i in asfo:
			path.curve.add_point(Vector2((i+1)*pl,-(pl*(i+1))))	
		prevlr += 1*asfo
		
	elif(name=="SChild"):
		for i in asfo:
			path.curve.add_point(Vector2(0,-((i+1)*pl)))
		
	else:
		fadedist = 0
		path.curve.add_point(Vector2(0,0))
	
	
	for i in lpp:
		var rdmNum = rng.randi_range(-1,1)
		prevlr += rdmNum
		path.curve.add_point(Vector2(prevlr*pl,-((i+1)*pl)-fadedist))		
	
	var newOrigin = Vector2(prevlr*pl, -(pl*lpp)-fadedist-150)
	
	if(recursionDepth!=1):
		var rdmNum = rng.randi_range(1,3)
		rdmNum = 4 ##todo 
		var neuepath
		if rdmNum<3:
			#links
			neuepath = rec(recursionDepth-1,newOrigin, "LChild")
			path.add_child(neuepath)
			
			#und rechts
			if rdmNum==2:
				neuepath = rec(recursionDepth-1,newOrigin, "RChild")
				path.add_child(neuepath)
				
		else:
			pass
			# nur rechts
			#neuepath = rec(recursionDepth-1,newOrigin, "RChild")
			#path.add_child(neuepath)
				
		neuepath = rec(recursionDepth-1,newOrigin, "SChild")
		path.add_child(neuepath)
			
	if name=="nofade":
		name = "SChild"
	path.name = name
	return path
	

func getInstance() -> Path2D:
	var scene = preload("res://scenes/visible_path.tscn") #preload geht aber load nit :huh:
	var path = scene.instantiate()
	path.curve = Curve2D.new()
	return path
	
