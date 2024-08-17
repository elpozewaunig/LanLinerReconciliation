extends Path2D


@export var tubele = []
@export var wasIstDas = "default"
@export var isDeadEnd = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(orderHiding):
		modulate.a -= 0.1 * delta
		
	if(modulate.a <= 0):
		hide()
		modulate.a = 1
		orderHiding = false

func _draw():
	pass
	

var orderHiding = false;

func _on_delete_branch():
	orderHiding = true;
	
	
var rng = RandomNumberGenerator.new()

func splitter(start, end, rec, marginfacSpeed, marginfacSlow, marginfacExtraSpeed, marginfacExtraSlow):
	if(rec==-1):
		return
	var l = (end-start)/2
	if(rec==0):
		var r =	rng.randi_range(1,5) ##wie viele
		if (r==1):
			var r2 = rng.randi_range(1,8)
			if(r2==1):
				addtubele(start+l*marginfacExtraSpeed,end-l*marginfacExtraSpeed,"extraspeed")
			else:
				addtubele(start+l*marginfacSpeed,end-l*marginfacSpeed,"speed")
			
		elif (r==2):
			var r2 = rng.randi_range(1,8)
			if(r2==1):
				addtubele(start+l+marginfacExtraSlow,end-l*marginfacExtraSlow,"extraslow")
			else:
				addtubele(start+l*marginfacSlow,end-l*marginfacSlow,"slow")
		return
		
	var mid = start+l
	splitter(start,mid,rec-1, marginfacSpeed, marginfacSlow, marginfacExtraSpeed, marginfacExtraSlow)
	splitter(mid,end,rec-1, marginfacSpeed, marginfacSlow, marginfacExtraSpeed, marginfacExtraSlow)

func addtubele(from,to,type):
	var section = {}
	section["from"] = from
	section["to"] = to
	section["type"] = type
	
	self.tubele.append(section)


func getBox():
	var scene = preload("res://scenes/box.tscn") #preload geht aber load nit :huh:
	var box = scene.instantiate()
	return box

func _ready():
	self.tubele = []
	var l = self.curve.get_baked_length()
	var start
	var end
	var splitrec
	
	if(self.wasIstDas=="startPatch"):
		start = 0
		end = 0
		splitrec = -1	
		
	if(self.wasIstDas=="LDeadEnd"
		or self.wasIstDas=="SDeadEnd"
		or self.wasIstDas=="RDeadEnd"):
		start = 0
		end = 0
		splitrec = -1
		var a = getDeadEndBlock()
		self.add_child(a)
		var lastpoint = self.curve.get_baked_points()[-1]
		a.position = Vector2(lastpoint.x,lastpoint.y)
		
	elif(self.wasIstDas=="straight"):
		start = 0+l*0.25
		end = l-l*0.25
		splitrec = 3
	elif(self.wasIstDas=="fork"):
		start = 0+l*0.25
		end = l-l*0.25
		splitrec = 3
	elif(self.wasIstDas=="sideZigZag"):
		start = 0+l*0.25
		end = l-l*0.25
		splitrec = 3
	elif(self.wasIstDas=="knotenTurn"):
		start = 0+l*0.25
		end = l-l*0.25
		splitrec = 3
	else: #"default"
		start = 0+l*0.25
		end = l-l*0.25
		splitrec = 3
	
	splitter(start,end,splitrec, 0.2,0.2,0.4,0.4) ##!!#!!#!!#!!#!!#!!#!!#!!
	
	var box = getBox()
	box.scale.x=3
	box.scale.y=3
	if(self.wasIstDas=="startPatch"):
		box.position.y+=65
	self.add_child(box)

	var bg = getBackgroundLine()
	for p in curve.get_baked_points():
		
		bg.add_point(p)
	bg.width = 85
	self.add_child(bg)
	
	var newbc = getRegularLine()
	for p in curve.get_baked_points():
		
		newbc.add_point(p)
	newbc.width = 20
	self.add_child(newbc)

	
	for el in tubele:
		var newc
		var l1 = float(el["from"])
		var l2 = float(el["to"])
		var col = Color.DEEP_PINK
		if(str(el["type"])=="speed"):
			newc = getSpeedLine()
		elif(str(el["type"])=="slow"):
			newc = getSlowLine()				
		elif(str(el["type"])=="extraspeed"):
			newc = getExtraSpeedLine()
		elif(str(el["type"])=="extraslow"):
			newc = getExtraSlowLine()	
	
		newc.add_point(curve.sample_baked(l1))
		for pointInbetween in getPointsInBetween(l1,l2, curve):
			newc.add_point(pointInbetween)
		newc.add_point(curve.sample_baked(l2))
		#draw_polyline(newc.get_baked_points(),col,10,true)
		newc.width = 25
		self.add_child(newc)
			
			
func getExtraSpeedLine() -> Line2D:
	var scene = preload("res://scenes/extraSpeedLine.tscn") #preload geht aber load nit :huh:
	var line = scene.instantiate()
	return line
func getExtraSlowLine() -> Line2D:
	var scene = preload("res://scenes/extraslowLine.tscn") #preload geht aber load nit :huh:
	var line = scene.instantiate()
	return line	
func getSpeedLine() -> Line2D:
	var scene = preload("res://scenes/speedLine.tscn") #preload geht aber load nit :huh:
	var line = scene.instantiate()
	return line
func getSlowLine() -> Line2D:
	var scene = preload("res://scenes/slowLine.tscn") #preload geht aber load nit :huh:
	var line = scene.instantiate()
	return line	
func getRegularLine() -> Line2D:
	var scene = preload("res://scenes/regularLine.tscn") #preload geht aber load nit :huh:
	var line = scene.instantiate()
	return line	
func getBackgroundLine() -> Line2D:
	var scene = preload("res://scenes/backgroundLine.tscn") #preload geht aber load nit :huh:
	var line = scene.instantiate()
	return line	
func getPointsInBetween(l1, l2, c):
	var arr = []
	var dist = 0.0
	for i in range(1,len(curve.get_baked_points())):
		dist+=curve.get_baked_points()[i-1].distance_to(curve.get_baked_points()[i])
		if(dist>l1 and dist<l2):
			arr.append(curve.get_baked_points()[i])
	return arr

func getDeadEndBlock() -> Sprite2D:
	var scene = preload("res://scenes/deadend.tscn") #preload geht aber load nit :huh:
	var b = scene.instantiate()
	return b	
		
