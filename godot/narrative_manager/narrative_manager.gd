class_name NarrativeManager
extends Node2D


enum FiredState {OK, WARNING, ALMOST_FIRED}

signal update(message: String)

@export var TIME_BEFORE_RANDOM_MESSAGE: float = 30.0

@export var angry_npc_warning_threshold: Array[int] = [5, 10, 15]

@export var almost_fired_to_warning_messages: Messages
@export var warning_to_ok_messages: Messages
@export var ok_to_warning_messages: Messages
@export var warning_to_almost_fired_messages: Messages
@export var random_message: Messages

var angry_npc_count: int = 0

var _current_state: FiredState = FiredState.OK
var _elapsed_time_before_random_message: float = 0.0


func _process(delta: float) -> void:
    if _current_state != FiredState.OK:
        return
    
    _elapsed_time_before_random_message += delta
    if _elapsed_time_before_random_message > TIME_BEFORE_RANDOM_MESSAGE:
        update_message(_get_message_from(random_message))
        _elapsed_time_before_random_message = 0.0


func update_angry_npc_count(count: int) -> void:
    angry_npc_count = count
    if angry_npc_count > angry_npc_warning_threshold[0] and _current_state == FiredState.OK:
        _current_state = FiredState.WARNING
        update_message(_get_message_from(ok_to_warning_messages))
    elif angry_npc_count > angry_npc_warning_threshold[1] and _current_state == FiredState.WARNING:
        _current_state = FiredState.ALMOST_FIRED
        update_message(_get_message_from(warning_to_almost_fired_messages))
    elif angry_npc_count < angry_npc_warning_threshold[0] and _current_state == FiredState.WARNING:
        _current_state = FiredState.OK
        _elapsed_time_before_random_message = 0.0
        update_message(_get_message_from(warning_to_ok_messages))
    elif angry_npc_count < angry_npc_warning_threshold[1] and _current_state == FiredState.ALMOST_FIRED:
        _current_state = FiredState.WARNING
        update_message(_get_message_from(almost_fired_to_warning_messages))
    

func _get_message_from(messages: Messages) -> String:
    return messages.message.pick_random()


func update_message(message: String) -> void:
    update.emit(message)
