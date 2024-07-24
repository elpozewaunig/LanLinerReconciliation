extends "res://scripts/Area2DButton.gd"

var game_scene = SceneManager.game_scene

func _on_clicked():
	get_tree().change_scene_to_packed(game_scene)
