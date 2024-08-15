extends Area2DButton

var game_scene = SceneManager.game_scene

func _on_clicked():
	get_tree().change_scene_to_packed(game_scene)
