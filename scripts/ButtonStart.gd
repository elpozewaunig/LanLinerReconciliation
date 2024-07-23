extends "res://scripts/Area2DButton.gd"

var main_scene = preload("res://scenes/main.tscn")

func _on_clicked():
	get_tree().change_scene_to_packed(main_scene)


func _on_credits_button_clicked():
	hide()


func _on_credits_exit_button_clicked():
	show()
