extends Area3D

@export var node_to_focus : Node3D

func _on_body_entered(body):
	var player = body as CharacterBody3D
	player.make_camera_focus(node_to_focus)


func _on_body_exited(body):
	var player = body as CharacterBody3D
	player.reset_camera_focus()
