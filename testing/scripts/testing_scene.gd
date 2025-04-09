extends CanvasLayer

func _process(_delta : float) -> void:
	if Input.is_key_pressed(KEY_R) && !LoadingSystem.is_loading():
		LoadingSystem.load_scene("res://menu/main_menu.tscn")
