extends AnimationTree

@export var blend_speed : float = 10.0
@export var model_rotation_speed : float = 5.0

var player : CharacterBody3D
var model : Node3D

var walk_blend : float
var glide_blend : float
var target_velocity : Vector3

func init(_player : CharacterBody3D) -> void:
	player = _player
	model = get_parent()

func _process(_delta : float) -> void:


	handle_walk_anim(_delta)
	if !handle_glide_anim(_delta):
		target_velocity = lerp(target_velocity, player.velocity, blend_speed * _delta)
	handle_model_rotation_towards_velocity()


func handle_glide_anim(_delta : float) -> bool:
	var velocity = player.velocity
	var is_gliding = player.is_currently_gliding
	var gravity_dir : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

	var dot_prod = velocity.dot(gravity_dir)
	var blend_val := 0.0

	if is_gliding && dot_prod > 0.0:
		blend_val = 1.0
		var horizontal_vel = Vector3(velocity.x, 0, velocity.z).normalized()
		target_velocity = lerp(target_velocity, horizontal_vel, model_rotation_speed * _delta)


	glide_blend = lerp(glide_blend, blend_val, _delta)
	self["parameters/glide_blend/blend_amount"] = glide_blend

	return is_gliding && dot_prod > 0.0

func handle_walk_anim(_delta : float) -> void:
	var velocity = player.velocity
	var blend_val := 1.0 if velocity.length() > 0.0 else 0.0

	walk_blend = lerp(walk_blend, blend_val, blend_speed * _delta)
	self["parameters/walk_blend/blend_amount"] = walk_blend

func handle_model_rotation_towards_velocity() -> void:
	var velocity = player.velocity
	if velocity.length() > 0:
		model.look_at(model.global_position + target_velocity,player.up_direction, true)
