extends Area2DButton

@onready var credits = $"/root/Menu/UI/Credits"

func _on_clicked():
	credits.hide()
