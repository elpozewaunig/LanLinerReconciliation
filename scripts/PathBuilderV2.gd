extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var rng = RandomNumberGenerator.new()

var recursions = 3
var extraDuplicates = 4
var gapBetweenDuplicates = 80

func createPath():
	var root = Node2D.new()
	var lane = Node2D.new()
	var neuepath = genSingleBranch(recursions, Vector2(0,0),"start")
	lane.add_child(neuepath)
	lane.name = "lane0"
	root.add_child(lane)
	for i in extraDuplicates:
		var dupli = lane.duplicate()
		dupli.position = Vector2(dupli.position.x+(gapBetweenDuplicates*(i+1)), dupli.position.y)
		dupli.name = "lane"+str(i+1)
		root.add_child(dupli)
	
	root.name = "root"
	root.position = Vector2(root.position.x,root.position.y)
	return root
	
func genSingleBranch(recursionDepth: int, origin: Vector2, name:String):
	#Erstelle einen neuen Path
	var path = getInstance()
	#Setze seinen Local-Origin zum Ende vom Letzten
	path.position = Vector2(origin.x,origin.y)
	#1. Point (0,0)
	var newOrigin = Vector2(0,0)
	path.curve.add_point(newOrigin)
	# Namen geben (falls special wie "start" wird unten überschrieben)
	path.name = name
	# Choose aus random depending welche kind (Origin muss auch durchgegeben werden)
	if(name=="LChild"):
		newOrigin = chooseRandomC(path.curve, 0,0,-1)
	elif(name=="RChild"):
		newOrigin = chooseRandomC(path.curve, 0,0,1)
	elif(name=="SChild"):
		newOrigin = chooseRandomS(path.curve,0,0)
	elif(name=="start"):
		newOrigin = chooseStart(path.curve,0,0)
		path.name = "SChild"
	
	# Rekursion terminieren
	if(recursionDepth==0):
		return path
	
	# (Ende vom Pfad, "Weggabelung" = Children Appenden, Entweder LS, SR oder LSR) 
	var rdmNum = rng.randi_range(1,3)
	var neuepath
	if rdmNum<3:
		#Links
		neuepath = genSingleBranch(recursionDepth-1,newOrigin, "LChild")
		path.add_child(neuepath)
		
		#Links.. und Rechts dazu?
		if rdmNum==2:
			neuepath = genSingleBranch(recursionDepth-1,newOrigin, "RChild")
			path.add_child(neuepath)
			
	else:
		pass
		#Nur Rechts
		neuepath = genSingleBranch(recursionDepth-1,newOrigin, "RChild")
		path.add_child(neuepath)
	
	#Gerade
	neuepath = genSingleBranch(recursionDepth-1,newOrigin, "SChild")
	path.add_child(neuepath)
	
	return path
	
func chooseRandomS(c, x, y):
	var rdmNum = rng.randi_range(1,2)
	if(rdmNum==1):
		return pSVanilla(c, x, y)
	if(rdmNum==2):
		return pSZigZag(c, x, y)
	if(rdmNum==3): ## todo
		return pSWavey(c, x, y)
func chooseRandomC(c, x,y, vorzeichen):
	var rdmNum = rng.randi_range(1,1)
	if(rdmNum==1):
		return pCFork(c, x, y, vorzeichen)
	elif(rdmNum==2):
		return pC90Turn(c, x, y, vorzeichen)
	elif(rdmNum==3):
		return pCdoubleUTurn(c, x, y, vorzeichen)
	
func chooseStart(c,x,y):
	return startPathPatch(c,x,y)
	
func startPathPatch(c,x,y):
	var s = Vector2(x,y-500)
	c.add_point(s)
	return s
	
func pSVanilla(c,x,y):
	var s = Vector2(x,y-2000)
	c.add_point(s)
	return s
	
func pSZigZag(c,x,y):
	var a = paddingS(c,x,y)
	x = a.x
	y = a.y
	var paddingstraightBefore = 0
	var paddingStraightAfter = 0
	var flip = getRandomSign()
	var l = 2000
	var w = 120
	var divisions = 8
	var dfac = l/divisions
	c.add_point(Vector2(x,y-paddingstraightBefore))
	c.add_point(Vector2(x,y-dfac/2-paddingstraightBefore))
	for i in divisions:
		c.add_point(Vector2(x+90*flip,y-(dfac*(i+1))-paddingstraightBefore))
		
		flip*=-1
	c.add_point(Vector2(x,y-l-(dfac/2)-paddingstraightBefore))
	c.add_point(Vector2(x,y-l-(dfac/2)-paddingstraightBefore-paddingStraightAfter))
	y = y-l-paddingstraightBefore-paddingStraightAfter
	var b = paddingS(c,x,y)
	x = b.x
	y = b.y
	return Vector2(x,y)

func paddingS(c,x,y):
	return Vector2(x,y-250)

func pSWavey(c,x,y): ##todo
	return Vector2(x,y-500)
# random +1 oder -1


func pCFork(c, x, y, sign): # y -750
	x+=500*sign
	y-=500
	c.add_point(Vector2(x,y))
	var a = paddingS(c,x,y)
	return chooseRandomS(c,a.x,a.y)

func pC90Turn(c,x,y,sign):
	x+=500*sign
	y-=500
	c.add_point(Vector2(x,y))
	x+=2500*sign
	c.add_point(Vector2(x,y))
	x+=500*sign
	y-=500
	c.add_point(Vector2(x,y))
	return Vector2(x,y)

func pCdoubleUTurn(c,x,y,sign):
	x+=500*sign
	y-=500
	c.add_point(Vector2(x,y))
	x+=1000*sign
	c.add_point(Vector2(x,y))
	x+=500*sign
	y+=500
	c.add_point(Vector2(x,y))
	y+=500
	c.add_point(Vector2(x,y))
	x+=500*-sign
	y+=500
	c.add_point(Vector2(x,y))
	y+=1500
	return Vector2(x,y)

func getRandomSign():
	return rng.randi_range(1,2)*2-3

func getInstance() -> Path2D:
	var scene = preload("res://scenes/visible_path.tscn") #preload geht aber load nit :huh:
	var path = scene.instantiate()
	path.curve = Curve2D.new()
	return path

