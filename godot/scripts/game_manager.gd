extends Node2D

const NPC_class = preload("res://objects/npc/npc.tscn")

@export var MIN_NPC_RESPAWN_TIME: float = 4.0
@export var MAX_NPC_RESPAWN_TIME: float = 8.0

@export var starting_npc_count: int = 5
@export var elevator: Elevator = null

@onready var rooms: Array[Node] = $World/SpaceStation/Rooms.get_children()
@onready var _npcs: Node2D = $World/NPCs
@onready var _npc_spawn_timer: Timer = $World/NPCSpawnTimer
@onready var _control_panel: Panel = %ControlPanel

var current_npc_count: int = 0
var _angry_npc_count: int = 0


func _ready() -> void:
    randomize()

    if elevator == null:
        push_error("no elevator")
        return
    
    AudioManager.play_music(SoundBank.background_music)
    # mute for now
    AudioManager.mute_bgm(true)

    for i in range(starting_npc_count):
        _spawn_npc()

    elevator.door_opened.connect(_on_elevator_door_opened)
    _restart_npc_spawn_timer()
    
    _control_panel.set_speed_cursor(elevator.current_speed)
    _control_panel.speed_cursor_changed.connect(elevator.on_speed_value_changed)
    _control_panel.open_gates_pressed.connect(elevator.on_open_gates)
    _control_panel.close_gates_pressed.connect(elevator.on_close_gates)
    _control_panel.start_elevator_pressed.connect(elevator.on_start_elevator)
    _control_panel.stop_elevator_pressed.connect(elevator.on_stop_elevator)


func _spawn_npc() -> void:
    var non_full_rooms: Array[Room] = []
    for room: Room in rooms:
        if not room.slot_manager.is_full():
            non_full_rooms.append(room)

    if len(non_full_rooms) == 0:
        return

    var random_room: Room = non_full_rooms.pick_random()
    var spawn_position: Vector2 = random_room.npc_spawn.global_position
    var npc: NPC = NPC_class.instantiate()
    _npcs.add_child(npc)
    npc.position = spawn_position

    var available_colors: Array = Enum.NPCColors.values()
    available_colors.erase(random_room.color)
    npc.color = available_colors.pick_random()

    var slot: Slot = random_room.slot_manager.get_first_available_slot()
    random_room.add_npc_inside(npc, slot)
    npc.go_to_slot(slot)

func _on_elevator_door_opened() -> void:
    var snapped_room: Room = elevator.get_snapped_room()
    if snapped_room == null:
        return # do nothing, if somehow the door opened without snapping
    
    # Start releasing people
    var spawn_point:Marker2D = snapped_room.get_spawn_point()
    var npc_to_release: NPC = null

    # Find first npc with matching colour
    var filter_to_room_color: Callable = func(npcs: Array[NPC]):
        # iterate backward for better performance (negligible, but still)
        for i in range(len(npcs)-1, -1, -1):
            if npcs[i].color == snapped_room.color:
                return npcs.pop_at(i)
        return null

    elevator.start_loading_people()
    while not elevator.is_empty():
        # TODO: add a filter to only let people that want to leave out
        npc_to_release = elevator.pop_npc_from_inside(filter_to_room_color)
        
        # no more matching the filter, stop
        if npc_to_release == null:
            break

        var targets: Array[Node2D] = [
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

    _on_all_npc_released()

func _on_all_npc_released() -> void:
    var snapped_room: Room = elevator.get_snapped_room()
    if snapped_room == null:
        return # do nothing, if somehow the door opened without snapping

    # Start entering the elevator
    var npc_to_enter: NPC = null

    while not elevator.is_full() and not snapped_room.is_empty():
        npc_to_enter = snapped_room.pop_npc_from_inside()

        # elevator is not full so there is at least one slot
        var slot = elevator.slot_manager.get_first_available_slot() # not null :)
        elevator.add_npc_inside(npc_to_enter, slot)
        var targets: Array[Node2D] = [
            snapped_room.get_entrance_position(),
            elevator.get_entrance_position(),
            slot,
            ]
        npc_to_enter.state_machine.transition_to(
            NPCStatesUtil.StatesName.move_to,
            {
                NPCStatesUtil.Message.target: targets
            }
        )
        await npc_to_enter.arrived_at_slot
        
    elevator.stop_loading_people()


func _on_npc_spawn_timer_timeout() -> void:
    _spawn_npc()
    _restart_npc_spawn_timer()


func _restart_npc_spawn_timer() -> void:
    var random_respawn_time: float = randf_range(MIN_NPC_RESPAWN_TIME, MAX_NPC_RESPAWN_TIME)
    _npc_spawn_timer.start(random_respawn_time)

func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel"):
        Events.pause()
