extends Control

@export var decimal_places = 3

@onready var player_label = $Time
@onready var enemy_label = $EnemyTime

var player_end_reached = false
var enemy_end_reached = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player_label.modulate.a = 0
	enemy_label.modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_end_reached:
		player_label.show()
		player_label.modulate.a += delta
		if player_label.modulate.a > 1:
			player_label.modulate.a = 1
			
	if player_end_reached and enemy_end_reached:
		enemy_label.show()
		enemy_label.modulate.a += delta
		if enemy_label.modulate.a > 1:
			enemy_label.modulate.a = 1


func _on_player_end_reached(time):
	player_end_reached = true
	if enemy_end_reached:
		player_label.position.y -= 200
	else:
		player_label.position.y -= 300
	var time_rounded = round(time * pow(10, decimal_places)) / pow(10, decimal_places)
	player_label.text = str(time_rounded)


func _on_enemy_end_reached(time):
	enemy_end_reached = true
	if player_end_reached:
		enemy_label.position.y -= 200
	else:
		enemy_label.position.y -= 300
	var time_rounded = round(time * pow(10, decimal_places)) / pow(10, decimal_places)
	enemy_label.text = str(time_rounded)
