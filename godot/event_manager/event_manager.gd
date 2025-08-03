class_name EventManager
extends Node2D


signal broken_room_repaired(room: Room)

enum EventType {NONE, BROKEN_DOOR, BROKEN_SPEED, VIP}

const TIME_BEFORE_TECH_GUY: float = 3.0

const NPC_class = preload("res://objects/npc/npc.tscn")

const TIME_BEFORE_FIRST_EVENT: float = 15.0
const MIN_WINDOW: float = 20.0
const MAX_WINDOW: float = 30.0
const VIP_NUMBER: int = 3

const BROKEN_ELEVATOR_MESSAGE: String = "Operator, the elevator speed is broken. I'll send you a tech guy."
const BROKEN_ROOM_MESSAGE: String = "Operator, one of the room's door is broken. I'll send you a tech guy."
const VIP_MESSAGE: String = "Operator, three VIPs are about to arrive. Make them a top priority."

@onready var _timer: Timer = $Timer

var game_manager: GameManager
var tech_guy_present: bool = false

var current_event: EventType = EventType.NONE
var vip_conveyed: int = 0


func _ready() -> void:
    _timer.start(TIME_BEFORE_FIRST_EVENT)


func _setup_timer_for_next_event() -> void:
    var time_before_next_event: float = randf_range(MIN_WINDOW, MAX_WINDOW)
    _timer.start(time_before_next_event)


func _on_timer_timeout() -> void:
    var possible_event_function: Array[Callable] = []
    if not tech_guy_present:
        possible_event_function.append(_play_slow_elevator_event)
        possible_event_function.append(_play_broken_door_event)
    if game_manager.current_npc_count + VIP_NUMBER + 1 < game_manager.max_npc_count:
        print(game_manager.current_npc_count, "/", game_manager.max_npc_count)
        possible_event_function.append(_play_vip_event)
        
    if possible_event_function.is_empty():
        _setup_timer_for_next_event()
    else:
        possible_event_function.pick_random().call()


func _play_broken_door_event() -> void:
    if tech_guy_present:
        _setup_timer_for_next_event()
        return
    current_event = EventType.BROKEN_DOOR
    var non_broken_nor_docked_room: Array[Node] = game_manager.rooms.filter(
        func(room: Room): return not room.door_broken and room != game_manager.elevator.get_snapped_room()
    )
    var broken_room: Room = non_broken_nor_docked_room.pick_random()
    broken_room.set_broken_to(true)
    
    game_manager._narrative_manager.update_message(BROKEN_ROOM_MESSAGE)
    
    if not tech_guy_present:
        _spawn_tech_guy()
    

func _play_slow_elevator_event() -> void:
    if tech_guy_present:
        _setup_timer_for_next_event()
        return
    current_event = EventType.BROKEN_SPEED
    game_manager.elevator.set_broken_speed_to(true)
    
    game_manager._narrative_manager.update_message(BROKEN_ELEVATOR_MESSAGE)
    
    if not tech_guy_present:
        _spawn_tech_guy()
    

func _play_vip_event() -> void:
    while game_manager._spawning_npc:
        await get_tree().create_timer(0.5).timeout
    
    game_manager._npc_spawn_timer.stop()
    current_event = EventType.VIP
    game_manager._narrative_manager.update_message(VIP_MESSAGE)
    
    for i in range(VIP_NUMBER):
        game_manager._spawn_npc(NPC.Type.VIP)
    
    game_manager._restart_npc_spawn_timer()



func on_vip_conveyed() -> void:
    vip_conveyed += 1
    print("vip conveyed ", vip_conveyed)
    if vip_conveyed == VIP_NUMBER:
        _on_all_vip_conveyed()


func _on_all_vip_conveyed() -> void:
    vip_conveyed = 0
    current_event = EventType.NONE
    _setup_timer_for_next_event()


func on_tech_guy_arrived_in_elevator(tech_guy: NPC) -> void:
    if current_event == EventType.BROKEN_SPEED:
        tech_guy.repair()
        await tech_guy.on_repair_finished
        current_event = EventType.NONE
        game_manager.elevator.set_broken_speed_to(false)
        
        _setup_timer_for_next_event()


func we_still_need_tech_guy() -> bool:
    if current_event == EventType.BROKEN_SPEED or current_event == EventType.BROKEN_DOOR:
        return true
    else:
        return false

func _spawn_tech_guy() -> void:
    await get_tree().create_timer(TIME_BEFORE_TECH_GUY).timeout
        
    game_manager._spawn_npc(NPC.Type.TECH_GUY)
    tech_guy_present = true


func on_tech_guy_arrived_at_broken_door(tech_guy: NPC, room: Room) -> void:
    tech_guy.repair()
    await tech_guy.on_repair_finished
    room.set_broken_to(false)
    broken_room_repaired.emit(room)
    current_event = EventType.NONE
    
    _setup_timer_for_next_event()
