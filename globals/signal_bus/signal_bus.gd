extends Node

signal death
signal game_end
signal collectible_count_changed

func _ready() -> void:
	death.connect(on_death)

func on_death() -> void:
	CheckpointSystem.reset_collectibles()
	#TODO: Add other Global death functionality
