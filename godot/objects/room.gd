@tool
extends RoomBase
class_name Room

signal door_closed
signal door_opened
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
@export_range(0, 5) var decal_to_use: int = 0:
    set(value):
        if not is_node_ready():
            await ready
        decal_to_use = value
        _decal.region_rect.position.x = 126 * decal_to_use

@onready var npc_spawn: Marker2D = $NPCSpawn
@onready var _door: AnimatedSprite2D = $Door
@onready var pivot: Node2D = $Pivot
@onready var _decal: Sprite2D = $Pivot/Decal
@onready var _broken_room_mask: Sprite2D = $Pivot/BrokenRoomMask
@onready var _broken_door_particles: CPUParticles2D = $BrokenDoorParticles


# people exit management
var next_people_leaving_idx: int = 0
var waiting_npc: NPC = null
var door_broken: bool = false


func _ready() -> void:
    set_broken_to(false)


func cycle_next_people_leaving_idx() -> void:
    next_people_leaving_idx = posmod((next_people_leaving_idx-1), number_npc_inside()) if number_npc_inside() > 0 else 0
    waiting_npc = null


func reset_waiting_npc() -> void:
    next_people_leaving_idx = 0
    waiting_npc = null

func start_exiting_people():
    reset_waiting_npc()


func ask_npc_coming(tech_guy: bool = false) -> void:
    # Ask NPC to come
    if tech_guy:
        # This should always return the tech guy as we ensure a tech guy is in the room before calling `ask_npc_coming(true)`
        waiting_npc = get_tech_guy_from_inside()
    else:
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
    if waiting_npc.type == NPC.Type.TECH_GUY:
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
    
    if waiting_npc.type == NPC.Type.TECH_GUY:
        tech_guy_in_elevator.emit(waiting_npc)
    
    cycle_next_people_leaving_idx()

func get_spawn_point() -> Marker2D:
    return npc_spawn


func get_tech_guy_point() -> Marker2D:
    return slot_manager.get_special_slot(Slot.Type.BROKEN_DOOR) as Marker2D
    

func open_door() -> void:
    if not door_broken:
        _door.play("open")
        await _door.animation_finished
        door_opened.emit()


func close_door() -> void:
    _door.play("close")
    await _door.animation_finished
    door_closed.emit()
    

func get_entrance_position() -> Marker2D:
    return entrance_position


func set_broken_to(value: bool) -> void:
    door_broken = value
    if door_broken:
        _broken_room_mask.show()
        _broken_door_particles.emitting = true
    else:
        _broken_room_mask.hide()
        _broken_door_particles.emitting = false
        
