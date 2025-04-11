extends Node

signal death

func _ready() -> void:
	death.connect(on_death)

func on_death() -> void:
	#TODO: Add Death functionality
	pass
