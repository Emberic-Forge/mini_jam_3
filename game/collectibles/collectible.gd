extends Area3D
class_name Collectible

var collected_flag = false

func _on_body_entered(_body: Node3D) -> void:
	if not collected_flag:
		Global.collectibles_count += 1
		collected_flag = true
		hide()

func un_collect() -> void:
	if collected_flag:
		Global.collectibles_count -= 1
		collected_flag = false
		show()
