extends Control


@export var intro_scene: PackedScene = null


func _on_button_pressed() -> void:
    get_tree().change_scene_to_packed(intro_scene)
