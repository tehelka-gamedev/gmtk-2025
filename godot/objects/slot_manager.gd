extends Node2D
class_name SlotManager
# Slots are defined by their children being only Node2D type!

var _available_slots: Array[Slot] = []
var _occupied_slots: Array[Slot] = []

func _ready() -> void:
    for c in get_children():
        if not c is Slot:
            continue
        var s:Slot = c
        if s.available:
            _available_slots.push_back(s)
        else:
            _occupied_slots.push_back(s)
        
func get_first_available_slot() -> Slot:
    if len(_available_slots) == 0:
        return null
    return _available_slots[0]

func get_last_available_slot() -> Slot:
    if len(_available_slots) == 0:
        return null
    return _available_slots[-1]

func get_random_available_slot() -> Slot:
    if len(_available_slots) == 0:
        return null
    return _available_slots[randi_range(0, len(_available_slots)-1)]

func reserve_slot(s:Slot) -> void:
    if _available_slots.find(s) == -1:
        push_error("Tried to reserve a slot that was not there!")
        return
    s.available = false

func release_slot(s:Slot) -> void:
    if _occupied_slots.find(s) == -1:
        push_error("Tried to release a slot that was not there!")
        return
    s.available = true

func is_full() -> bool:
    return _available_slots.is_empty()
