extends Path2D


@export var tubele = []


var alpha = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(alpha-0.1*delta <= 0):
		hide()
		orderHiding = false
		alpha = 1
		modulate = alpha
	if(orderHiding):
		alpha -= 0.1 * delta
	modulate = alpha
	

func _draw():
	pass
	

var orderHiding = false;

func _on_delete_branch():
	orderHiding = true;
	
	
var rng = RandomNumberGenerator.new()

func splitter(start, end, rec):
	var l = (end-start)/2
	if(rec==0):
		var r =	rng.randi_range(1,3)
		if (r==1):
			var r2 = rng.randi_range(1,8)
			if(r2==1):
				addtubele(start+l*0.8,end-l*0.8,"extraspeed")
			else:
				addtubele(start+l*0.6,end-l*0.6,"speed")
			
		elif (r==2):
			var r2 = rng.randi_range(1,8)
			if(r2==1):
				addtubele(start+l+0.8,end-l*0.8,"extraslow")
			else:
				addtubele(start+l*0.6,end-l*0.6,"slow")
		return
		
	var mid = start+l
	splitter(start,mid,rec-1)
	splitter(mid,end,rec-1)

func addtubele(from,to,type):
	self.tubele.append([from,to,type])


func getBox():
	var scene = preload("res://scenes/box.tscn") #preload geht aber load nit :huh:
	var box = scene.instantiate()
	return box

func _ready():
	self.tubele = []
	var l = self.curve.get_baked_length()
	var start = 0+l*0.25
	var end = l-l*0.25

	splitter(start,end,3)
	
	var box = getBox()
	self.add_child(box)
	
	var newbc = getRegularLine()
	for p in curve.get_baked_points():
		
		newbc.add_point(p)
	newbc.width = 15
	self.add_child(newbc)

	
	for el in tubele:
		var newc
		var l1 = float(el[0])
		var l2 = float(el[1])
		var col = Color.DEEP_PINK
		if(str(el[2])=="speed"):
			newc = getSpeedLine()
		elif(str(el[2])=="slow"):
			newc = getSlowLine()				
		elif(str(el[2])=="extraspeed"):
			newc = getExtraSpeedLine()
		elif(str(el[2])=="extraslow"):
			newc = getExtraSlowLine()	
	
		newc.add_point(curve.sample_baked(l1))
		for pointInbetween in getPointsInBetween(l1,l2, curve):
			newc.add_point(pointInbetween)
		newc.add_point(curve.sample_baked(l2))
		#draw_polyline(newc.get_baked_points(),col,10,true)
		newc.width = 50
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
func getPointsInBetween(l1, l2, c):
	var arr = []
	var dist = 0.0
	for i in range(1,len(curve.get_baked_points())):
		dist+=curve.get_baked_points()[i-1].distance_to(curve.get_baked_points()[i])
		if(dist>l1 and dist<l2):
			arr.append(curve.get_baked_points()[i])
	return arr
		
		
