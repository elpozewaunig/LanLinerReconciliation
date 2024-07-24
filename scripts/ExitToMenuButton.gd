extends "res://scripts/Area2DButton.gd"

var menu_scene = SceneManager.menu_scene

func _on_clicked():
	get_tree().change_scene_to_packed(menu_scene)
