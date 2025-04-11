extends Node3D

func _ready() -> void:
	PauseSystem.pause_game = true
	#CheckpointSystem.init_system(collectibles_parent)
