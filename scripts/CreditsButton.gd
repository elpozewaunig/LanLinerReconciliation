extends Area2DButton

@onready var credits = $"/root/Menu/UI/Credits"

func _on_clicked():
	credits.show()
	hide()


func _on_credits_exit_button_clicked():
	show()
