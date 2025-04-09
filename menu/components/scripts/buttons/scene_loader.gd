class_name LoadScene extends Button

@export_file var scene_to_load : String


func _ready() -> void:
	button_down.connect(_load_scene)


func _load_scene() -> void:
	LoadingSystem.load_scene(scene_to_load)
