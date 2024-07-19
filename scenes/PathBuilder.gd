extends Node2D


var pl = 500 # how long is a path-line in px
var gap = 160 # how many px gap between the duplis 
var dc = 4 # how many extra duplicates
var ec = 3 # how many path elements (recursion!) careful with that
var lpp = 8 # how many lines per path? (additional to asfo)
var asfo = 5 # how many lines after a split to fade out into a normal path ,sideways "fork"
var asfof = 5 # after asfo, straight "fork" (SChild is straight for asfo+asfof)
var bsfo = 4 # how many lines before a split to fade into a a splitter
var rng = RandomNumberGenerator.new()
var debuggap = 0
var debugmove = 0#1500

func createPath():
	var root = Node2D.new()
	var lane = Node2D.new()
	var neuepath = rec(ec, Vector2(0,0),"nofade")
	lane.add_child(neuepath)
	lane.name = "lane0"
	root.add_child(lane)
	for i in dc:
		var dupli = lane.duplicate()
		dupli.position = Vector2(dupli.position.x+(gap*(i+1)), dupli.position.y)
		dupli.name = "lane"+str(i+1)
		root.add_child(dupli)
	
	root.name = "root"
	root.position = Vector2(root.position.x,root.position.y+debugmove)
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
		prevlr -= 1*asfo
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
	
	for i in asfof:
		path.curve.add_point(Vector2(prevlr*pl,-((i+1)*pl)-fadedist))
	
	fadedist+=asfof*pl
	
	
	for i in lpp:
		var rdmNum
		if(name=="LChild"): 
			rdmNum = rng.randi_range(-1,0)
		elif(name=="SChild"):
			rdmNum = rng.randi_range(-1,1)
		elif(name=="RChild"):
			rdmNum = rng.randi_range(0,1)
		else:
			rdmNum = 0
		prevlr += rdmNum
		path.curve.add_point(Vector2(prevlr*pl,-((i+1)*pl)-fadedist))		
	
	for i in bsfo:
		path.curve.add_point(Vector2(prevlr*pl, (-(pl*lpp)-fadedist)-((i+1)*pl)))
	
	var newOrigin = Vector2(prevlr*pl, -(pl*lpp)-fadedist-(bsfo*pl)-debuggap)
	
	if(recursionDepth!=1):
		var rdmNum = rng.randi_range(1,3)
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
			neuepath = rec(recursionDepth-1,newOrigin, "RChild")
			path.add_child(neuepath)
				
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
	
