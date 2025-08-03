class_name EndControl
extends Control


enum Type {WIN, LOSE}


signal continue_pressed

@export var win_message: VAMessage = null
@export var lose_message: VAMessage = null

@onready var _text_label: Label = %TextLabel

var end_type: Type


func show_end(type: Type) -> void:
    end_type = type
    if type == Type.WIN:
        set_message(win_message)
    elif type == Type.LOSE:
        set_message(lose_message)
    show()


func set_message(message: VAMessage) -> void:
    if message.text:
        _text_label.text = message.text
    if message.audio_va != null:
        AudioManager.play_sound_effect(message.audio_va)


func _on_button_pressed() -> void:
    print(end_type)
    if end_type == Type.WIN:
        hide()
        continue_pressed.emit()
    elif end_type == Type.LOSE:
        pass
        # go back to main menu
