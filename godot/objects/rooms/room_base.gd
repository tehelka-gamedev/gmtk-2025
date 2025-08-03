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
    

func default_pop_npc(npcs: Array[NPC]) -> NPC:
    return npcs.pop_back()

# Remove an npc from the list matching the given filter (null if none found)
# Argument:
# - filter: a Callable( npcs: Array[NPC]) -> NPC
# If no filter is given, remove the npc from the (end of the) list and returns it
func pop_npc_from_inside(filter: Callable = default_pop_npc) -> NPC:
    var npc: NPC = filter.call(npc_inside)
    
    if not npc:
        return null
    npc.slot.release()

    return npc

func number_npc_inside() -> int:
    return len(npc_inside)

func get_npc_from_inside(idx:int) -> NPC:
    if idx < 0 or idx >= len(npc_inside):
        push_error("Trying to get npc from inside at index '%d', invalid. Size='%d'." % len(npc_inside))
        return null
    return npc_inside[idx]

func is_tech_guy_in_room() -> bool:
    for npc: NPC in npc_inside:
        if npc.type == NPC.Type.TECH_GUY:
            return true
    return false

func get_tech_guy_from_inside() -> NPC:
    for npc: NPC in npc_inside:
        if npc.type == NPC.Type.TECH_GUY:
            return npc
    return null

func remove_npc_from_room(npc: NPC) -> void:
    npc_inside.erase(npc)
    npc.slot.release()

func release_all_npc_inside() -> Array[NPC]:
    var array_to_return:Array[NPC] = npc_inside.duplicate()
    npc_inside = []
    return array_to_return

func is_empty() -> bool:
    return slot_manager.is_empty()

func is_full() -> bool:
    return slot_manager.is_full()

func get_entrance_position() -> Marker2D:
    push_error("get_entrance_position() not implemented in %s!" % name)
    return null
