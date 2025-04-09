class_name RemapButton extends HBoxContainer

var input_name : Label
var button : Button

var target_action : String


func init(new_action : String) -> void:
	assert(!new_action.is_empty(), "Attempted to assign a null action!")

	name = "remap_%sbutton" % target_action

	input_name = get_child(0)
	input_name.name = "input_name_%s" % new_action

	button = get_child(1)
	button.name = "button_%s" % new_action

	button.toggled.connect(_rebind_key)

	target_action = new_action
	set_process_unhandled_key_input(false)
	_display_current_key()

func _rebind_key(is_button_pressed : bool) -> void:
	if target_action.is_empty():
		push_warning("Missing action in %s" % get_path())
		return

	set_process_unhandled_key_input(is_button_pressed)
	if is_button_pressed:
		button.text = "<press a key>"
		modulate = Color.YELLOW
		release_focus()
	else:
		_display_current_key()
		modulate = Color.WHITE
		# Grab focus after assigning a key, so that you can go to the next
		# key using the keyboard.
		grab_focus()

# NOTE: You can use the `_input()` callback instead, especially if
# you want to work with gamepads.
func _unhandled_key_input(event: InputEvent) -> void:
	# Skip if pressing Enter, so that the input mapping GUI can be navigated
	# with the keyboard. The downside of this approach is that the Enter
	# key can't be bound to actions.
	if event is InputEventKey and event.keycode != KEY_ENTER:
		remap_action_to(event)
		button.button_pressed = false

func remap_action_to(event: InputEvent) -> void:
	if target_action.is_empty():
		push_warning("Missing action in %s" % get_path())
		return
	# We first change the event in this game instance.
	InputMap.action_erase_events(target_action)
	InputMap.action_add_event(target_action, event)
	# And then save it to the keymaps file.
	KeyPersistence.keymaps[target_action] = event
	KeyPersistence.save_keymap()
	button.text = event.as_text()

func _display_current_key() -> void:
	if target_action.is_empty():
		push_warning("Missing action in %s" % get_path())
		return
	var current_key := InputMap.action_get_events(target_action)[0].as_text()
	button.text = current_key
	input_name.text = target_action
