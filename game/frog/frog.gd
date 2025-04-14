extends Node3D

@onready var raycast = $Frog/RayCast3D
@onready var death_timer = $DeathTimer
@onready var timer_label = $CanvasLayer/TimerLabel

@export var tongue : Node3D

var tween: Tween

func _ready() -> void:
	tongue.visible = false

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
	tongue.visible = true
	var player = raycast.get_collider() as CharacterBody3D
	player.make_camera_focus(tongue)

	# Have the frog attack!
	var origin = raycast.global_transform.origin
	var hit_point = raycast.get_collision_point()
	var direction = (hit_point - origin).normalized()
	var distance = origin.distance_to(hit_point)
	var target_scale = Vector3(1, 1, distance)
	var midpoint = origin + direction * (distance / 2.0)
	# Build a look-at transform toward the hit point
	var target_transform = tongue.global_transform.looking_at(hit_point, Vector3.UP)
	target_transform.origin = midpoint
	# Kill existing tween if running
	if tween and tween.is_running():
		tween.kill()
	var tween = get_tree().create_tween()
	# Tween scale
	tween.tween_property(tongue, "scale", target_scale, 0.5)
	# Tween position and rotation
	tween.tween_property(tongue, "global_transform", target_transform, 0.5)
	tween.tween_property(tongue, "scale", 0.1, 0.5)
	tween.finished.connect(func():
		SignalBus.death.emit()
		player.reset_camera_focus()
		tongue.visible = false
		)
