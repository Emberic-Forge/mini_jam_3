class_name Transition extends AnimationPlayer

@export var transition_in_anim : String
@export var transition_out_anim : String

func _ready() -> void:
	animation_finished.connect(func(animation: String):
		queue_free()
		)


func transition_in() -> void:
	play(transition_in_anim)

func transition_out() -> void:
	play(transition_out_anim)
