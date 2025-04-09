class_name OpenMenu extends Button

@export var menu_element_to_open : Node
@export var hide_parent : bool

func _ready() -> void:
	assert(menu_element_to_open, "Assign a menu element at %s!" % get_path())

	button_down.connect(_open_menu)
	menu_element_to_open.visible = false

func _open_menu() -> void:
	PauseSystem.enter_element(menu_element_to_open, hide_parent)
