extends Node2D


var pl = 150 # how long is a path-line in px
var gap = 160 # how many px gap between the duplis 
var dc = 4 # how many extra duplicates
var ec = 5 # how many path elements (recursion!) careful with that
var lpp = 24 # how many lines per path? (additional to asfo)
var asfo = 10 # how many lines after a split to fade out into a normal path ,sideways "fork"
var asfof = 5 # after asfo, straight "fork" (SChild is straight for asfo+asfof)
var bsfo = 4 # how many lines before a split to fade into a a splitter
var rng = RandomNumberGenerator.new()
var debuggap = 0
var debugmove = 0#1500



func createPath():
	
	
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

	
