extends AnimationTree

@export var blend_speed : float = 10.0
@export var model_rotation_speed : float = 5.0

var player : CharacterBody3D
var model : Node3D

var walk_blend : float
var glide_blend : float
var target_motion_dir : Vector3

func init(_player : CharacterBody3D) -> void:
	player = _player
	model = get_parent().get_parent()

func _process(_delta : float) -> void:


	handle_walk_anim(_delta)
	handle_glide_anim(_delta)
	handle_model_rotation_towards_velocity(_delta)


func handle_glide_anim(_delta : float) -> void:
	var velocity = player.velocity
	var blend_val := 1.0 if not player.is_on_floor() else 0.0

	glide_blend = lerp(glide_blend, blend_val, blend_speed * _delta)
	self["parameters/glide_blend/blend_amount"] = glide_blend

func handle_walk_anim(_delta : float) -> void:
	var velocity = player.velocity
	var blend_val := 1.0 if velocity.length() > 0.0 else 0.0

	walk_blend = lerp(walk_blend, blend_val, blend_speed * _delta)
	self["parameters/walk_blend/blend_amount"] = walk_blend

func handle_model_rotation_towards_velocity(_delta : float) -> void:
	var motion_dir = player.velocity.normalized()
	if motion_dir.length() > 0.1 && abs(motion_dir.dot(Vector3.UP)) < 0.9:
		target_motion_dir = lerp(target_motion_dir, motion_dir, _delta * model_rotation_speed)
	else:
		target_motion_dir = lerp(target_motion_dir, Vector3(motion_dir.x, 0, motion_dir.z), _delta * model_rotation_speed)
		target_motion_dir.y = 0

	if target_motion_dir.length() > 0.1:
		model.look_at(model.global_position + target_motion_dir, Vector3.UP, true)
