extends CanvasLayer

func _ready() -> void:
	PauseSystem.pause_game = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
