class_name Quit extends Button

func _ready() -> void:
	button_down.connect(_on_quit)

func _on_quit() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
