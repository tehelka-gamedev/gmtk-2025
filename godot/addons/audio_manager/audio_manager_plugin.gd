@tool
extends EditorPlugin

const AUTOLOAD_NAME = "AudioManager"


func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

func _enable_plugin():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/audio_manager/audio_manager.tscn")

func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_NAME)