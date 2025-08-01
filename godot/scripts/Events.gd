extends Node

signal pause_game
signal unpause_game
@warning_ignore("unused_signal")
signal return_to_main_menu

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS # just in case O:)

func pause() -> void:
    get_tree().paused = true
    pause_game.emit()

func unpause() -> void:
    get_tree().paused = false
    unpause_game.emit()
