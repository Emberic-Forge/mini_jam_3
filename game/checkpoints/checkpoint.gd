extends Area3D
class_name Checkpoint

func _on_body_entered(_body: Node3D) -> void:
	CheckpointSystem.checkpoint_collected(self)
	await get_tree().create_timer(0.25).timeout
	queue_free()
