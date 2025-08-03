class_name EndControl
extends Control


enum Type {WIN, LOSE}


signal continue_pressed


@export_file("*.tscn") var main_menu_path: String

@export var win_message: VAMessage = null
@export var lose_message: VAMessage = null

@onready var _text_label: Label = %TextLabel

var end_type: Type
var audio_va: AudioStreamPlayer = null


func show_end(type: Type) -> void:
    end_type = type
    if type == Type.WIN:
        AudioManager.play_sound_effect(SoundBank.job_well_done)
        set_message(win_message)
    elif type == Type.LOSE:
        set_message(lose_message)
    show()


func set_message(message: VAMessage) -> void:
    if message.text:
        _text_label.text = message.text
    if message.audio_va != null:
        audio_va = AudioManager.play_sound_effect(message.audio_va)


func _on_button_pressed() -> void:
    hide()
    if audio_va:
        audio_va.stop()
        
    if end_type == Type.WIN:
        continue_pressed.emit()
    elif end_type == Type.LOSE:
        get_tree().change_scene_to_file(main_menu_path)
