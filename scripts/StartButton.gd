extends Area2DButton

var game_scene = SceneManager.game_scene

func _on_clicked():
	get_tree().change_scene_to_packed(game_scene)


func _on_credits_button_clicked():
	hide()


func _on_credits_exit_button_clicked():
	show()
