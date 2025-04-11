extends Node3D

@onready var collectibles_parent = $CollectiblesParent

func _ready() -> void:
	CheckpointSystem.init_system(collectibles_parent)
