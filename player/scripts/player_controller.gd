extends CharacterBody3D

@export var player_settings : PlayerSettings
@export var camera : InterpolatedCamera3D

@onready var gravity_dir = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var gravity = player_settings.get_gravity()

@onready var camera_base : Node3D = $arm
@onready var camera_anchor : Node3D = $arm/camera_anchor
@onready var animation_tree : AnimationTree = $model/player/AnimationTree
@onready var shape :CollisionShape3D = $shape


@onready var glide_bar : ProgressBar = $SubViewport/GlideBar
@onready var glide_timer : Timer = $GlideTimer

var camera_input_direction : Vector2
var glide_status : int
var prev_glide_status : int
var control_up_direction : Vector3

const GLIDE_IDLE := 0
const GLIDE := 1
const GLIDE_CD := 2

func _ready() -> void:
	animation_tree.init(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	camera.set_camera_anchor(camera_anchor)
	camera.set_up_direction(up_direction)
	camera.set_focus_point(self)

	glide_timer.wait_time = player_settings.glide_duration_in_seconds
	glide_timer.timeout.connect(func(): glide_status = GLIDE_CD)

	glide_bar.max_value = player_settings.glide_duration_in_seconds

	Global.player_ref = self
	SignalBus.death.connect(on_death)

	reset_player()

func make_camera_focus(node_to_focus : Node3D) -> void:
	const CAM_LENGTH_OFFSET := 5.0

	camera.look_at_node(node_to_focus)

	var dir = (global_position - node_to_focus.global_position).normalized()
	var desired_offset = dir * CAM_LENGTH_OFFSET
	var offset = dir * min(CAM_LENGTH_OFFSET, camera_collision_length(desired_offset, CAM_LENGTH_OFFSET))

	camera.move_camera_towards_node(self,false, offset)
	camera.override_camera()

func camera_collision_length(dir : Vector3, default : float = 5.0) -> float:
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + dir)
	var result = space_state.intersect_ray(query)
	if !result:
		return default

	var hit_pos : Vector3 = result["position"]
	var length = (global_position - hit_pos).length()
	return length


func reset_camera_focus() -> void:
	camera.reset_camera()



func reset_player() -> void:
	glide_status == GLIDE_IDLE
	glide_timer.stop()
	velocity = Vector3.ZERO

func _unhandled_input(event : InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_motion:
		camera_input_direction = event.screen_relative * player_settings.mouse_sensitivity

func _process(_delta : float) -> void:
	handle_camera_control(_delta)


func handle_camera_control(delta : float) -> void:
	camera_base.rotation.x -= camera_input_direction.y * delta
	camera_base.rotation.x = clamp(camera_base.rotation.x, deg_to_rad(player_settings.camera_min_vertical_rotation), deg_to_rad(player_settings.camera_max_vertical_rotation))

	camera_base.rotation.y -= camera_input_direction.x * delta
	camera_input_direction = Vector2.ZERO

func _physics_process(_delta : float) -> void:
	handle_gravity(_delta)
	handle_jump(_delta)
	handle_movement(_delta)
	move_and_slide()
	update_glide_bar()


func calculate_local_input() -> Vector3:
	var raw_input := Vector2(Input.get_axis(player_settings.move_left_action, player_settings.move_right_action), Input.get_axis(player_settings.move_forward_action, player_settings.move_backward_action))
	var input_dir = camera.transform.basis.x * raw_input.x + camera.transform.basis.z * raw_input.y
	input_dir.y = 0
	return input_dir

func handle_gravity(_delta : float) -> void:
	print_status()

	if is_on_floor():
		reset_gliding()
		return

	if is_currently_gliding():
		apply_glide_gravity(_delta)
		update_glide_slider()
		print("Attempting to glide")
	else:
		apply_gravity(_delta)
	pass

func print_status() -> void:
	if prev_glide_status == glide_status && glide_status != GLIDE:
		return

	prev_glide_status = glide_status
	var status = ("Paused" if glide_timer.paused else "Unpaused")

	match glide_status:
		GLIDE_IDLE:
			print("Glide: Idle (Timer Status: %s)" % status)
		GLIDE:
			print("Glide: Gliding - Duration : %f (Timer Status: %s)" % [glide_timer.time_left, status])
		GLIDE_CD:
			print("Glide: CD (Timer Status: %s)" % status)

func reset_gliding() -> void:
	glide_status = GLIDE_IDLE
	glide_timer.stop()
	pass

func is_currently_gliding() -> bool:
	var dot = velocity.dot(gravity_dir)
	return Input.is_action_pressed(player_settings.jump_action) && dot > 0.0 && glide_status != GLIDE_CD

func apply_glide_gravity(_delta : float) -> void:
	if glide_status == GLIDE_IDLE:
		start_gliding()

	var target_gravity = gravity * player_settings.glide_hover_amm
	velocity += gravity_dir * target_gravity * _delta
	glide_timer.paused = false

func apply_gravity(_delta : float) -> void:
	var dot = velocity.dot(gravity_dir)
	var target_gravity = gravity * _delta
	if dot >= player_settings.fall_detection_range:
		target_gravity = gravity * player_settings.fall_multiplier * _delta

	velocity += gravity_dir * target_gravity
	glide_timer.paused = true

func start_gliding() -> void:
	glide_timer.paused = false
	glide_timer.start()
	glide_status = GLIDE

func update_glide_slider() -> void:
	glide_bar.visible = glide_status == GLIDE
	glide_bar.value = glide_timer.time_left


func handle_jump(_delta : float) -> void:
	if Input.is_action_just_pressed(player_settings.jump_action) && is_on_floor():
		apply_jump()

func apply_jump() -> void:
	var jump_velocity = player_settings.calculate_jump_velocity()
	velocity += up_direction * jump_velocity

func handle_movement(delta : float) -> void:
	var input_dir := calculate_local_input()
	var target_velocity := input_dir * (player_settings.glide_speed if is_currently_gliding else player_settings.movement_speed)
	target_velocity.y = velocity.y
	if input_dir:
		velocity = lerp(velocity, target_velocity, player_settings.ground_acceleration * 10.0 * delta)
	else:
		velocity = lerp(velocity, Vector3(0, velocity.y, 0), player_settings.ground_decceleration * 10.0 * delta)


func update_glide_bar() -> void:
	if glide_bar.visible && is_on_floor():
		glide_bar.hide()
	if not glide_timer.is_stopped():
		glide_bar.value = glide_timer.time_left

func on_death() -> void:
	# TODO: Death animation & more
	global_position = CheckpointSystem.last_checkpoint_position
	reset_player()
