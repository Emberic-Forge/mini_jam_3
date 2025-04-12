extends CanvasLayer

@onready var collectible_label = $CollectibleCounter/Count

func _ready() -> void:
	SignalBus.collectible_count_changed.connect(on_collectible_count_changed)

func on_collectible_count_changed() -> void:
	collectible_label.text = ("%s/%s" % [CheckpointSystem.collectible_count, 
										CheckpointSystem.collectible_max])
