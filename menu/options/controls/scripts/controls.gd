class_name Controls extends Node

@export_file var input_remap_button_file : String
@export var input_actions : Array[String]

var remap_button_scene : PackedScene
@onready var order = $margin/order


func _ready() -> void:
	# Load the remap button
	remap_button_scene = load(input_remap_button_file)

	for action in input_actions:
		assert(InputMap.has_action(action), "Action %s missing!" % action)
		_create_input_button(action)

func _create_input_button(action : String) -> void:
	var ins = remap_button_scene.instantiate() as RemapButton
	order.add_child(ins)
	ins.init(action)
	print("Initialized remap button for %s" % action)
