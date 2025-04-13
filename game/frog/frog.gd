extends Node3D

@onready var raycast = $Frog/RayCast3D
@onready var death_timer = $DeathTimer
@onready var timer_label = $CanvasLayer/TimerLabel

func _physics_process(_delta: float) -> void:
	if not Global.player_ref:
		return
	
	# Raycast to Player position
	var to = Global.player_ref.global_position
	raycast.target_position = (to - raycast.global_position) * 100
	
	var collider: Node3D = raycast.get_collider()
	if not collider:
		return
	
	# Check if raycast collides with Player. 
	# If yes, start timer, otherwise stop timer.
	if collider.is_in_group("Player"):
		if death_timer.is_stopped():
			death_timer.start()
			timer_label.show()
		timer_label.text = "%.1f" % death_timer.time_left
	else:
		death_timer.stop()
		timer_label.hide()


func _on_death_timer_timeout() -> void:
	SignalBus.death.emit()
