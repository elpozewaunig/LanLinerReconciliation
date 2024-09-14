extends Area2DButton

@onready var credits = $"/root/Menu/UI/Credits"

func _process(delta):
	super._process(delta)
	if Input.is_action_just_pressed("ui_cancel") and credits.visible:
		clicked.emit()

func _on_clicked():
	credits.hide()
