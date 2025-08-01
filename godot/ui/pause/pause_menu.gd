class_name PauseMenu
extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # important, otherwise pause menu will be paused :o)
	Events.pause_game.connect(_on_pause)
	Events.unpause_game.connect(_on_unpause)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		Events.unpause()
	# elif event.is_action_pressed("exit"):
	# 	get_viewport().set_input_as_handled()
	# 	Events.unpause()
	# 	Events.return_to_main_menu.emit()
		

func _on_pause() -> void:
	show()

func _on_unpause() -> void:
	hide()
