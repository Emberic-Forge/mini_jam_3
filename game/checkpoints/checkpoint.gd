extends Area3D

func _on_body_entered(_body: Node3D) -> void:
	Global.last_checkpoint_position = position
