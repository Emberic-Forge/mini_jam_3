extends CanvasLayer

@export var transition_scene : PackedScene
@export var loading_scene : PackedScene

var scene_to_load : String
var loading_screen : LoadingScreen
var exit_loading : bool = false
var has_loaded : bool = false

signal on_loading_complete
signal on_loading_started

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func load_scene(target_scene : String, multi_threaded : bool = false) -> void:
	PauseSystem.clear_element_stack()
	scene_to_load = target_scene
	exit_loading = false
	has_loaded = false

	var transition_scene_ins := transition_scene.instantiate()
	add_child(transition_scene_ins)
	transition_scene_ins.transition_in()

	transition_scene_ins.animation_finished.connect(func(animation: String):
		ResourceLoader.load_threaded_request(scene_to_load, "", multi_threaded)
		loading_screen = loading_scene.instantiate()
		add_child(loading_screen)
		loading_screen.update_loading_percent(0)
		exit_loading = true
		)

	on_loading_started.emit()

func is_loading() -> bool:
	return !has_loaded

func _process(_delta : float) -> void:
	if scene_to_load.is_empty() or !exit_loading:
		return

	var progress = []
	var status := ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	if loading_screen:
		loading_screen.update_loading_percent(roundi(progress[0]*100))

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			loading_screen.queue_free()

			var scene := ResourceLoader.load_threaded_get(scene_to_load)
			get_tree().change_scene_to_packed(scene)
			scene_to_load = ""

			var transition_scene_ins := transition_scene.instantiate()
			add_child(transition_scene_ins)
			transition_scene_ins.transition_out()

			on_loading_complete.emit()
			has_loaded = true
