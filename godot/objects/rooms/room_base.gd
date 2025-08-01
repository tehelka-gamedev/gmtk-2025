extends Node2D
class_name RoomBase
# Base for an object that can holds npc

@warning_ignore_start("unused_signal")
signal full # emitted when it is full
signal empty # emitted when it is empty
signal waiting_for_someone
@warning_ignore_restore("unused_signal")

@export var slot_manager: SlotManager

var npc_inside: Array[NPC] = []

func add_npc_inside(npc:NPC, slot:Slot) -> void:
    if not slot.reserve():
        push_error("Could not add npc '%s' in slot '%s', slot is occupied!" % [npc.name, slot.name])
        return
    npc_inside.push_back(npc)
    npc.slot = slot
    

# Remove an npc from the (end of the) list and returns it
# If there are none, returns none and prints an error
func pop_npc_from_inside() -> NPC:
    var npc: NPC = npc_inside.pop_back()

    if not npc:
        push_error("Tried to pop an npc but there are no left in the elevator, something is wrong!!")
        return null
    npc.slot.release()

    return npc

func release_all_npc_inside() -> Array[NPC]:
    var array_to_return:Array[NPC] = npc_inside.duplicate()
    npc_inside = []
    return array_to_return

func is_empty() -> bool:
    return slot_manager.is_empty()

func is_full() -> bool:
    return slot_manager.is_full()
