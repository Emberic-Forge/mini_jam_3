extends CanvasLayer

func _ready() -> void:
	PauseSystem.pause_game = true
	visible = false
	PauseSystem.starting_element_to_enter = self
