extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var rng = RandomNumberGenerator.new()

var lineLength = 800 #(alles wird damit multiplied)

var recursions = 3
var extraDuplicates = 4
var gapBetweenDuplicatesX = 60
var gapBetweenDuplicatesY = 0
func createPath():
	var root = Node2D.new()
	var lane = Node2D.new()
	var neuepath = genSingleBranch(recursions, Vector2(0,0),"start")
	lane.add_child(neuepath)
	lane.name = "lane0"
	root.add_child(lane)
	for i in extraDuplicates:
		var dupli = lane.duplicate()
		dupli.position = Vector2(
			dupli.position.x+(gapBetweenDuplicatesX*(i+1)), 
			dupli.position.y+(gapBetweenDuplicatesY*(i+1)))
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
	
	#deadend
	if name=="SDeadEnd":
		path.curve.add_point(Vector2(newOrigin.x,newOrigin.y-lineLength*0.75))
		path.wasIstDas = name
		path.isDeadEnd = true
		path.name = "SChild"
		return path
	if name=="LDeadEnd":
		path.curve.add_point(Vector2(newOrigin.x-lineLength/2,newOrigin.y-lineLength*0.75))
		path.wasIstDas = name
		path.isDeadEnd = true
		path.name = "LChild"
		return path	
	if name=="RDeadEnd":
		path.curve.add_point(Vector2(newOrigin.x+lineLength/2,newOrigin.y-lineLength*0.75))
		path.wasIstDas = name
		path.isDeadEnd = true
		path.name = "RChild"
		return path
	# Choose aus random depending welche kind (Origin muss auch durchgegeben werden)
	if(name=="LChild"):
		newOrigin = chooseRandomC(path, 0,0,-1)
	elif(name=="RChild"):
		newOrigin = chooseRandomC(path, 0,0,1)
	elif(name=="SChild"):
		newOrigin = chooseRandomS(path,0,0)
	elif(name=="start"):
		newOrigin = chooseStart(path,0,0)
		path.name = "SChild"
	
	# Rekursion terminieren
	if(recursionDepth==0):
		var a = getStartEndBlock()
		a.position = Vector2(newOrigin.x,newOrigin.y)
		path.add_child(a)
		return path
	
	# (Ende vom Pfad, "Weggabelung" = Children Appenden, Entweder LS, SR oder LSR) 
	var rdmNum = rng.randi_range(1,3)
	var neuepath
	
	var blocker = rng.randi_range(1,3) 
	
	# 0 = keiner
	# 1 = nur mitte
	# 2 = 1x Blockage Links/Rechts (es kann sein dass es Rechts dazu gibt, diese ist dnan frei)
		# also sprich es kann sein: Links Blockiert, Rechts Blockiert oder Links Blockiert Rechts frei
		# Rechts blockiert Links frei gibt es nicht aber won't bother
	# 3 = #2 mit Mitte auch Blockiert (konsi: es R-dazu geben; damit 1 viable weg existiert)
	
	var blockSRandom = rng.randi_range(0,3)
	
	if rdmNum<3:
		#Links
		if blockSRandom>=2:
			neuepath = genSingleBranch(recursionDepth-1,newOrigin, "LDeadEnd")
			path.add_child(neuepath)
		else:
			neuepath = genSingleBranch(recursionDepth-1,newOrigin, "LChild")
			path.add_child(neuepath)
		
		#Links.. und Rechts dazu?
		if rdmNum==2:
			neuepath = genSingleBranch(recursionDepth-1,newOrigin, "RChild")
			path.add_child(neuepath)
			
	else:
		#Nur Rechts
		if blockSRandom>=2:
			neuepath = genSingleBranch(recursionDepth-1,newOrigin, "RDeadEnd")
			path.add_child(neuepath)
		else:
			neuepath = genSingleBranch(recursionDepth-1,newOrigin, "RChild")
			path.add_child(neuepath)
	
	
	#Gerade
	if blockSRandom==1: # oben wird keiner blockiert, es gibt garantiert L oder R
		neuepath = genSingleBranch(recursionDepth-1,newOrigin, "SDeadEnd")
		path.add_child(neuepath)
	elif rdmNum<2 and blockSRandom==3: # wenns einen anderen gibt der frei ist, block den S dazu
		neuepath = genSingleBranch(recursionDepth-1,newOrigin, "SDeadEnd")
		path.add_child(neuepath)
	else:
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
	var rdmNum = rng.randi_range(1,3)
	if(rdmNum==1):
		return pCFork(c, x, y, vorzeichen)
	elif(rdmNum==2):
		return pCSideWaysZigZag(c, x, y, vorzeichen)
	elif(rdmNum==3):
		return pCKnotenTurn(c, x, y, vorzeichen)
func chooseStart(c,x,y):
	return startPathPatch(c,x,y)
	
func startPathPatch(c,x,y):
	var s = Vector2(x,y-lineLength*3)
	c.curve.add_point(s)
	c.wasIstDas = "startPatch"
	
	var a = getStartEndBlock()
	a.scale.x = 2.5
	a.scale.y = 2.5
	a.position.y -=12
	c.add_child(a)
	
	return s
	
func pSVanilla(c,x,y):
	var s = Vector2(x,y-lineLength*3)
	c.curve.add_point(s)
	c.wasIstDas = "straight"
	return s
	


func pSZigZag(c,x,y):
	var a = paddingS(c,x,y)
	x = a.x
	y = a.y
	var flip = getRandomSign()
	c.curve.add_point(Vector2(x,y))
	
	var l = lineLength*3
	var w = 120
	var divisions = 8
	var dfac = l/divisions

	var preflipX = x
	for i in divisions-1:
		x=w*flip
		y-=dfac
		c.curve.add_point(Vector2(x,y))
		flip*=-1
	
	x = preflipX
	y-=dfac
	c.curve.add_point(Vector2(x,y))
	c.wasIstDas = "zigzag"
	return paddingS(c,x,y)

func paddingS(c,x,y):
	var a = Vector2(x,y-lineLength)
	c.curve.add_point(a)
	return a

func pSWavey(c,x,y): ##todo
	return Vector2(x,y-500)
# random +1 oder -1


func pCFork(c, x, y, sign): # y -750
	x+=lineLength*sign
	y-=lineLength
	c.curve.add_point(Vector2(x,y))
	var a = paddingS(c,x,y)
	x = a.x
	y = a.y
	c.wasIstDas = "fork"
	return Vector2(x,y)

func pCSideWaysZigZag(c,x,y,sign):
	x+=lineLength*sign
	y-=lineLength
	c.curve.add_point(Vector2(x,y))
	x+=lineLength*0.5*sign
	y+=lineLength*0.5
	c.curve.add_point(Vector2(x,y))
	x+=lineLength*0.5*sign
	y-=lineLength*0.5
	c.curve.add_point(Vector2(x,y))
	var a = paddingS(c,x,y)
	x = a.x
	y = a.y
	c.wasIstDas = "sideZigZag"
	return Vector2(x,y)

func pCKnotenTurn(c,x,y,sign):
	x+=lineLength*2*sign
	y-=lineLength*2
	c.curve.add_point(Vector2(x,y))
	x+=lineLength*0.5*sign
	y+=lineLength*0.5
	c.curve.add_point(Vector2(x,y))
	x+=lineLength*0.5*-sign
	y+=lineLength*0.5
	c.curve.add_point(Vector2(x,y))
	x+=lineLength*-sign
	y-=lineLength
	c.curve.add_point(Vector2(x,y))
	var a = paddingS(c,x,y)
	x = a.x
	y = a.y
	c.wasIstDas = "knotenTurn"
	return Vector2(x,y)

func getRandomSign():
	return rng.randi_range(1,2)*2-3

func getInstance() -> Path2D:
	var scene = preload("res://scenes/visible_path.tscn") #preload geht aber load nit :huh:
	var path = scene.instantiate()
	path.curve = Curve2D.new()
	return path

func getStartEndBlock() -> Sprite2D:
	var scene = preload("res://scenes/levelstartend.tscn") #preload geht aber load nit :huh:
	var b = scene.instantiate()
	return b	
