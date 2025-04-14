extends Area3D

func _on_body_entered(body: Node3D) -> void:
	LoadingSystem.load_scene("res://menu/main_menu.tscn")
