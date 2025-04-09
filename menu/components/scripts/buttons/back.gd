class_name Back extends Button

func _ready() -> void:
	button_down.connect(_on_back)

func _on_back() -> void:
	PauseSystem.exit_element()
