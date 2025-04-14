class_name VolumeSlider extends HSlider


@export var bus_name : String

@onready var indx = AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	if bus_name.is_empty():
		push_warning("No bus assigned at '%s', skipping event!" % str(self.get_path()))
		return
	assert(indx != -1, "Invalid bus '%s' at '%s'" % [bus_name, str(self.get_path())])
	value = AudioServer.get_bus_volume_linear(indx)
	value_changed.connect(_on_volume_mod)
	step = 0.01
	max_value = 1.0
	min_value = 0.0

func _on_volume_mod(value : float) -> void:
	AudioServer.set_bus_volume_linear(indx, value)
	pass
