class_name SensitivitySlider extends HSlider

var player_res_path = "res://player/settings/player.tres"

func _ready() -> void:
	var player_res: PlayerSettings = ResourceLoader.load(player_res_path)
	value = player_res.mouse_sensitivity
	value_changed.connect(_on_value_changed)

func _on_value_changed(value: float) -> void:
	var player_res: PlayerSettings = ResourceLoader.load(player_res_path)
	player_res.mouse_sensitivity = value
	ResourceSaver.save(player_res, player_res_path)
	pass
