extends Path2D


@export var tubele = []



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	pass

func _ready():
	
	var newbc = getRegularLine()
	for p in curve.get_baked_points():
		
		newbc.add_point(p)
	newbc.width = 20
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
			
		newc.add_point(curve.sample_baked(l1))
		for pointInbetween in getPointsInBetween(l1,l2, curve):
			newc.add_point(pointInbetween)
		newc.add_point(curve.sample_baked(l2))
		#draw_polyline(newc.get_baked_points(),col,10,true)
		newc.width = 50
		self.add_child(newc)
			
			

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
		
		
