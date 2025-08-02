extends Node2D
class_name SlotManager
# Slots are defined by their children being only Node2D type!

var _available_slots: Array[Slot] = []
var _occupied_slots: Array[Slot] = []
var _broken_door_slot: Slot = null
var _broken_speed_slot: Slot = null


func _ready() -> void:
    for c in get_children():
        if not c is Slot:
            continue
        var s:Slot = c
        if s.type == Slot.Type.BROKEN_DOOR:
            _broken_door_slot = s
        elif s.type == Slot.Type.BROKEN_SPEED:
            _broken_speed_slot = s
        elif s.available:
            _available_slots.push_back(s)
        else:
            _occupied_slots.push_back(s)
        s.reserved.connect(_on_slot_reserved)
        s.released.connect(_on_slot_released)


func get_special_slot(type: Slot.Type) -> Slot:
    if type == Slot.Type.BROKEN_DOOR:
        if not _broken_door_slot:
            return null
        else:
            return _broken_door_slot
    elif type == Slot.Type.BROKEN_SPEED:
        if not _broken_speed_slot:
            return null
        else:
            return _broken_speed_slot

    return null


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

func is_full() -> bool:
    return _available_slots.is_empty() # no available slot

func is_empty() -> bool:
    return _occupied_slots.is_empty() # nothing occupied

func _on_slot_reserved(s: Slot) -> void:
    _available_slots.erase(s)
    _occupied_slots.append(s)

func _on_slot_released(s: Slot) -> void:
    _available_slots.append(s)
    _occupied_slots.erase(s)
