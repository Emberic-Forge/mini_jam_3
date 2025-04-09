class_name LoadingScreen extends CanvasLayer

@onready var loading_percent : Label = $margin/order/loading_percent

func update_loading_percent(value : int) -> void:
	loading_percent.text = str(value) + "%"
