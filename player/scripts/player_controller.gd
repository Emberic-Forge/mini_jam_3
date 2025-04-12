extends CharacterBody3D

@export var player_settings : PlayerSettings
@export var camera : InterpolatedCamera3D

@onready var gravity_dir = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var gravity = player_settings.get_gravity()

@onready var camera_base : Node3D = $arm
@onready var camera_anchor : Node3D = $arm/camera_anchor

@onready var glide_bar : ProgressBar = $SubViewport/GlideBar
@onready var glide_timer : Timer = $GlideTimer

var camera_input_direction : Vector2

var can_glide_flag : bool
var has_started_gliding : bool
var is_currently_gliding : bool

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	camera.set_camera_anchor(camera_anchor)
	camera.set_up_direction(up_direction)
	camera.set_focus_point(self)
	
	glide_timer.wait_time = player_settings.glide_duration_in_seconds

	SignalBus.death.connect(on_death)

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
	handle_movement()
	move_and_slide()
	update_glide_bar()


func calculate_local_input() -> Vector3:
	var raw_input := Vector2(Input.get_axis(player_settings.move_left_action, player_settings.move_right_action), Input.get_axis(player_settings.move_forward_action, player_settings.move_backward_action))
	var input_dir = camera.transform.basis.x * raw_input.x + camera.transform.basis.z * raw_input.y
	input_dir.y = 0
	return input_dir

func handle_gravity(_delta : float) -> void:
	if is_on_floor():
		can_glide_flag = true
		is_currently_gliding = false
		return
	var dot_prod = gravity_dir.dot(velocity.normalized())
	var target_gravity = gravity
	if Input.is_action_pressed(player_settings.jump_action) && dot_prod > 0.25 && can_glide_flag:
		if has_started_gliding:
			is_currently_gliding = true
			velocity = Vector3.ZERO
			glide_timer.start()
			glide_bar.show()
			has_started_gliding = false
		target_gravity = gravity * player_settings.glide_hover_amm
		velocity.y = -target_gravity
		print("Gliding: %f -> Velocity %s" % [target_gravity, str(velocity)])
		return
	elif dot_prod >= player_settings.fall_detection_range:
		target_gravity *= player_settings.fall_multiplier
	velocity += gravity_dir * target_gravity * _delta

func handle_jump(_delta : float) -> void:
	if Input.is_action_pressed(player_settings.jump_action) && is_on_floor():
		var jump_velocity = player_settings.calculate_jump_velocity()
		velocity += Vector3.UP * jump_velocity
		has_started_gliding = true

func handle_movement() -> void:
	var input_dir := calculate_local_input()
	var target_velocity := input_dir * (player_settings.glide_speed if is_currently_gliding else player_settings.movement_speed)
	target_velocity.y = velocity.y
	if input_dir:
		velocity = lerp(velocity, target_velocity, player_settings.ground_acceleration)
	else:
		velocity = lerp(velocity, Vector3(0, velocity.y, 0), player_settings.ground_decceleration)

func _on_glide_timer_timeout() -> void:
	can_glide_flag = false
	glide_bar.hide()

func update_glide_bar() -> void:
	if glide_bar.visible && is_on_floor():
		glide_bar.hide()
	if not glide_timer.is_stopped():
		glide_bar.value = glide_timer.time_left

func on_death() -> void:
	# TODO: Death animation & more
	global_position = CheckpointSystem.last_checkpoint_position
