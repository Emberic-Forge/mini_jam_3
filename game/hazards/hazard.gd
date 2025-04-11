extends Area3D

func _on_body_entered(body: Node3D) -> void:
	#TODO: Add Player Check
	SignalBus.death.emit()
