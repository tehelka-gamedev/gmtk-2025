@tool
extends RoomBase
class_name Room

signal tech_guy_in_elevator(tech_guy: NPC)
signal npc_is_waiting(room:Room, npc: NPC)

@export_category("Gameplay variables")
@export var color: Enum.NPCColors:
    set(value):
        if not is_node_ready():
            await ready
        color = value
        _decal.modulate = Enum.color_enum_to_rgb(color)


@export var entrance_position:Marker2D = null
@export var decal_to_use: bool = false:
    set(value):
        if not is_node_ready():
            await ready
        decal_to_use = value
        if decal_to_use:
            _decal.region_rect.position.x = 124
        else:
            _decal.region_rect.position.x = 0

@onready var npc_spawn: Marker2D = $NPCSpawn
@onready var _door: Sprite2D = $Door
@onready var pivot: Node2D = $Pivot
@onready var _decal: Sprite2D = $Pivot/Decal


# people exit management
var next_people_leaving_idx: int = 0
var waiting_npc: NPC = null

func cycle_next_people_leaving_idx() -> void:
    next_people_leaving_idx = posmod((next_people_leaving_idx-1), number_npc_inside()) if number_npc_inside() > 0 else 0
    waiting_npc = null


func reset_waiting_npc() -> void:
    next_people_leaving_idx = 0
    waiting_npc = null

func start_exiting_people():
    reset_waiting_npc()

func ask_npc_coming() -> void:
    # Ask NPC to come
    waiting_npc = get_npc_from_inside(next_people_leaving_idx)

    var targets: Array[Node2D] = [
            get_entrance_position()
            ]
    waiting_npc.state_machine.transition_to(
        NPCStatesUtil.StatesName.move_to,
        {
            NPCStatesUtil.Message.target: targets
        }
    )
    await waiting_npc.arrived_at_slot
    npc_is_waiting.emit(self, waiting_npc)

# make the currently waiting npc to stop waiting
func npc_denied() -> void: 
    if waiting_npc == null:
        push_error("Asked %s to deny npc waiting but no one is waiting, something is wrong" % name)
        return
    waiting_npc.go_back_to_slot()
    await waiting_npc.arrived_at_slot
    cycle_next_people_leaving_idx()

func abort_waiting() -> void:
    if waiting_npc == null:
        push_error("Asked %s to abort waiting but no one is waiting, something is wrong" % name)
        return
    waiting_npc.go_back_to_slot()
    await waiting_npc.arrived_at_slot
    reset_waiting_npc()
    

func transfer_waiting_npc_to_room(room:RoomBase) -> void:
    if waiting_npc == null:
        push_error("Asked %s to transfer waiting npc to room but no one is waiting, something is wrong" % name)
        return
    remove_npc_from_room(waiting_npc)

    var slot: Slot
    if waiting_npc.tech_guy:
        slot = room.slot_manager.get_special_slot(Slot.Type.BROKEN_SPEED)
    else:
        slot = room.slot_manager.get_first_available_slot() # not null :)
    room.add_npc_inside(waiting_npc, slot)
    var targets: Array[Node2D] = [
        room.get_entrance_position(),
        slot,
        ]
    waiting_npc.state_machine.transition_to(
        NPCStatesUtil.StatesName.move_to,
        {
            NPCStatesUtil.Message.target: targets
        }
    )
    await waiting_npc.arrived_at_slot
    
    if waiting_npc.tech_guy:
        tech_guy_in_elevator.emit(waiting_npc)
    
    cycle_next_people_leaving_idx()

func get_spawn_point() -> Marker2D:
    return npc_spawn


func open_door() -> void:
    _door.hide()


func close_door() -> void:
    _door.show()

func get_entrance_position() -> Marker2D:
    return entrance_position
