class_name PlayerSettings extends Resource

@export_group("Core")
@export var movement_speed : float = 5.0
@export var jump_height : float = 1.5
@export var ground_acceleration : float = 1.0
@export var ground_decceleration : float = 1.0
@export_group("Glide")
@export var glide_speed : float = 5.0
@export var glide_duration_in_seconds : float = 5.0
@export var glide_hover_amm : float = 0.15
@export_group("Gravity")
@export var fall_multiplier : float = 1.1
@export var fall_detection_range : float = -0.1
@export_group("Input")
@export var move_left_action : String
@export var move_forward_action : String
@export var move_right_action : String
@export var move_backward_action : String
@export var jump_action : String
@export_group("Camera")
@export var mouse_sensitivity : float = 0.5
@export var camera_min_vertical_rotation : float = -30.0
@export var camera_max_vertical_rotation : float = 60.0

func calculate_jump_velocity() -> float:
	var gravity := get_gravity()
	return sqrt(2 * gravity * jump_height)

func get_gravity() -> float:
	return ProjectSettings.get_setting("physics/3d/default_gravity") as float
