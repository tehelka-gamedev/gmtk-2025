class_name GameManager
extends Node2D

const TECH_GUY_COLOR: Color = Color.WHITE

const NPC_class = preload("res://objects/npc/npc.tscn")

@export var MIN_NPC_RESPAWN_TIME: float = 4.0
@export var MAX_NPC_RESPAWN_TIME: float = 8.0

@export var starting_npc_count: int = 5
@export var elevator: Elevator = null

@onready var rooms: Array[Node] = $World/SpaceStation/Rooms.get_children()
@onready var _npcs: Node2D = $World/NPCs
@onready var _npc_spawn_timer: Timer = $World/NPCSpawnTimer
@onready var _control_panel: Panel = %ControlPanel
@onready var _narrative_manager: NarrativeManager = $NarrativeManager
@onready var _event_manager: EventManager = $EventManager

var current_npc_count: int = 0
var _angry_npc_count: int = 0
var _conveyed_npc_count: int = 0
var _spawning_npc: bool = false
var max_npc_count: int = 0

# player choice
enum PlayerChoice
{
    ENTER,
    DENY,
    ABORT,
    NONE
}
signal player_choice_made(player_choice: PlayerChoice)
var _waiting_for_player_choice: bool = false

func _ready() -> void:
    randomize()

    if elevator == null:
        push_error("no elevator")
        return
    
    AudioManager.play_music(SoundBank.background_music)
    
    if OS.has_feature("editor"):
        AudioManager.mute_bgm(true)

    max_npc_count = 0
    var color_array: Array = Enum.NPCColors.values()
    for i: int in len(rooms):
        (rooms[i] as Room).color = color_array[i]
        (rooms[i] as Room).decal_to_use = i % 2
        (rooms[i] as Room).tech_guy_in_elevator.connect(_event_manager.on_tech_guy_arrived_in_elevator)
        max_npc_count += (rooms[i] as Room).slot_manager.get_child_count() - 1 # HACK minus 1 so we don't count the spot the for the broken door
    max_npc_count += elevator.slot_manager.get_child_count() - 1
    
    for i in range(starting_npc_count):
        _spawn_npc()

    elevator.door_opened.connect(_on_elevator_door_opened)
    _restart_npc_spawn_timer()
    
    _control_panel.set_speed_cursor(elevator.current_speed)
    
    elevator.speed_changed.connect(func(_new_speed: int, speed_idx: int): (
        _control_panel.set_speed_cursor(speed_idx)
    ))

    _control_panel.speed_cursor_changed.connect(elevator.set_speed_idx_no_signal)
    _control_panel.start_elevator_pressed.connect(elevator.on_start_elevator)
    _control_panel.stop_elevator_pressed.connect(elevator.on_stop_elevator)
    _narrative_manager.update.connect(_control_panel.message_panel.set_message)
    _event_manager.game_manager = self
    _event_manager.broken_room_repaired.connect(_on_broken_room_repaired)
    

func _on_npc_mood_state_changed(old_mood_state: MoodGauge.MoodState, new_mood_state: MoodGauge.MoodState) -> void:
    if new_mood_state == MoodGauge.MoodState.ANGRY:
        _angry_npc_count += 1
        _narrative_manager.update_angry_npc_count(_angry_npc_count)
        _control_panel.set_angry_npc_count(_angry_npc_count)
    if old_mood_state == MoodGauge.MoodState.ANGRY:
        _angry_npc_count -= 1
        _narrative_manager.update_angry_npc_count(_angry_npc_count)
        _control_panel.set_angry_npc_count(_angry_npc_count)


############### PLAYER INPUTS ###############

func _unhandled_input(event: InputEvent):
    handle_pause(event)
    handle_player_choice(event)

func handle_pause(event: InputEvent):
    if event.is_action_pressed("ui_cancel"):
        Events.pause()

func send_player_choice(player_choice:PlayerChoice) -> void:
    _waiting_for_player_choice = false
    player_choice_made.emit(player_choice)

func handle_player_choice(event: InputEvent) -> void:
    if not _waiting_for_player_choice:
        return
    
    if event.is_action_pressed("accept_npc_entering"):
        send_player_choice(PlayerChoice.ENTER)
    elif event.is_action_pressed("refuse_npc_entering"):
        send_player_choice(PlayerChoice.DENY)
    if event.is_action_pressed("player_choice_abort"):
        send_player_choice(PlayerChoice.ABORT)


############### Management of people exiting and entering elevator ###############

func _on_elevator_door_opened() -> void:
    var snapped_room: Room = elevator.get_snapped_room()
    if snapped_room == null:
        return # do nothing, if somehow the door opened without snapping
    
    # Start releasing people
    var spawn_point:Marker2D = snapped_room.get_spawn_point()
    var tech_guy_point: Marker2D = snapped_room.get_tech_guy_point()
    var npc_to_release: NPC = null

    # Find first npc with matching colour
    var filter_to_room_color: Callable = func(npcs: Array[NPC]):
        # iterate backward for better performance (negligible, but still)
        for i in range(len(npcs)-1, -1, -1):
            if (
                npcs[i].type == NPC.Type.TECH_GUY and snapped_room.door_broken
                or (npcs[i].type == NPC.Type.TECH_GUY and not _event_manager.we_still_need_tech_guy())
                or (npcs[i].color == snapped_room.color and not snapped_room.door_broken)
            ):
                return npcs.pop_at(i)
        return null

    elevator.start_loading_people()
    while not elevator.is_empty() or not elevator.slot_manager.get_special_slot(Slot.Type.BROKEN_SPEED).available:
        npc_to_release = elevator.pop_npc_from_inside(filter_to_room_color)
        if npc_to_release == null:
            break
        if npc_to_release.type == NPC.Type.TECH_GUY:
            _event_manager.tech_guy_present = false        
        
        var targets: Array[Node2D]
        if npc_to_release.type == NPC.Type.TECH_GUY and snapped_room.door_broken:
            targets = [
                elevator.get_entrance_position(),
                tech_guy_point
            ]
        else:
            targets = [
                elevator.get_entrance_position(),
                snapped_room.get_entrance_position(),
                spawn_point,
            ]
            npc_to_release.exiting = true
            
        npc_to_release.state_machine.transition_to(
            NPCStatesUtil.StatesName.move_to,
            {
                NPCStatesUtil.Message.target: targets
            }
        )
        await npc_to_release.arrived_at_slot
        
        if npc_to_release.type == NPC.Type.TECH_GUY:
            _event_manager.on_tech_guy_arrived_at_broken_door(npc_to_release, snapped_room)
            npc_to_release.state_machine.transition_to(NPCStatesUtil.StatesName.repair, {NPCStatesUtil.Message.target: [tech_guy_point, spawn_point]})
    
    if not snapped_room.door_broken:
        snapped_room.start_exiting_people()
        _release_from_snapped_room()
    else:
        elevator.stop_loading_people()


#### People delivery from room

func _release_from_snapped_room() -> void:
    var snapped_room: Room = elevator.get_snapped_room()
    if snapped_room == null:
        return # do nothing, if somehow the door opened without snapping
    
    if not snapped_room.is_empty():
        if not elevator.is_full():
            snapped_room.ask_npc_coming()
            snapped_room.npc_is_waiting.connect(_on_npc_waiting, CONNECT_ONE_SHOT)
        elif elevator.slot_manager.get_special_slot(Slot.Type.BROKEN_SPEED).available and snapped_room.is_tech_guy_in_room():
            var tech_guy: bool = true
            snapped_room.ask_npc_coming(tech_guy)
            snapped_room.npc_is_waiting.connect(_on_npc_waiting, CONNECT_ONE_SHOT)
        else:
            elevator.stop_loading_people()
    else:
        elevator.stop_loading_people()


func _on_npc_waiting(room: Room, _npc: NPC) -> void:
    var player_choice: PlayerChoice = await _ask_player_choice()

    match player_choice:
        PlayerChoice.ENTER:
            await room.transfer_waiting_npc_to_room(elevator)
            _release_from_snapped_room()
        PlayerChoice.DENY:
            await room.npc_denied()
            _release_from_snapped_room()
        PlayerChoice.ABORT:
            room.npc_denied()
            elevator.stop_loading_people()
        _:
            push_error("UNKNOWN PLAYER CHOICE %s" % player_choice)


func _ask_player_choice() -> PlayerChoice:
    _waiting_for_player_choice = true
    return await player_choice_made

        

############### NPC SPAWN ###############

func _spawn_npc(type: NPC.Type = NPC.Type.NORMAL) -> void:
    _spawning_npc = true
    
    var non_full_rooms: Array[Room] = []
    while non_full_rooms.is_empty():
        for room: Room in rooms:
            if not room.slot_manager.is_full() and not (type == NPC.Type.TECH_GUY and room.door_broken):
                non_full_rooms.append(room)
        if type != NPC.Type.TECH_GUY:
            break
        else:
            await get_tree().create_timer(1.0).timeout

    if len(non_full_rooms) == 0:
        _spawning_npc = false
        return

    var random_room: Room = non_full_rooms.pick_random()
    var spawn_position: Vector2 = random_room.npc_spawn.global_position
    var npc: NPC = NPC_class.instantiate()
    _npcs.add_child(npc)
    npc.position = spawn_position
    npc.type = type

    if type == NPC.Type.TECH_GUY:
        npc.set_color_directly(TECH_GUY_COLOR)
    else:
        var available_colors: Array = Enum.NPCColors.values()
        available_colors.erase(random_room.color)
        npc.color = available_colors.pick_random()
    
    if type != NPC.Type.NORMAL:
        npc.show_type_label()

    var slot: Slot = random_room.slot_manager.get_first_available_slot()
    random_room.add_npc_inside(npc, slot)
    npc.go_to_slot(slot)

    if type != NPC.Type.TECH_GUY:
        npc.mood_gauge.mood_state_changed.connect(_on_npc_mood_state_changed)
        npc.arrived_at_target_room.connect(_on_npc_arrived_at_target_room)
        if type == NPC.Type.VIP:
            npc.mood_gauge.regen_per_tick = -10
            npc.arrived_at_target_room.connect(_event_manager.on_vip_conveyed)
            
    current_npc_count += 1
    
    _spawning_npc = false
    

func _on_npc_spawn_timer_timeout() -> void:
    if not _spawning_npc:
        _spawn_npc()
    _restart_npc_spawn_timer()


func _restart_npc_spawn_timer() -> void:
    var random_respawn_time: float = randf_range(MIN_NPC_RESPAWN_TIME, MAX_NPC_RESPAWN_TIME)
    _npc_spawn_timer.start(random_respawn_time)


func _on_npc_arrived_at_target_room() -> void:
    _conveyed_npc_count += 1
    _control_panel.set_conveyed_npc_count(_conveyed_npc_count)

    
func _on_broken_room_repaired(room: Room) -> void:
    var snapped_room: Room = elevator.get_snapped_room()
    if snapped_room == null:
        return # do nothing, if somehow the door opened without snapping
    elif room == snapped_room:
        _on_elevator_door_opened()
