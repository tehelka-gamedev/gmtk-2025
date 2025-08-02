class_name EventManager
extends Node2D


const TIME_BEFORE_TECH_GUY: float = 3.0

const NPC_class = preload("res://objects/npc/npc.tscn")

const MIN_WINDOW: float = 5.0
const MAX_WINDOW: float = 10.0

const BROKEN_ELEVATOR_MESSAGE: String = "Operator, the elevator speed is broken. I'll send you a tech guy."
const BROKEN_ROOM_MESSAGE: String = "Operator, one of the room's door is broken. I'll send you a tech guy."
const VIP_MESSAGE: String = "Operator, a VIP is about to arrive. Make it a top priority."

@onready var _timer: Timer = $Timer

var game_manager: GameManager

var event_function: Array[Callable] = [
    #_play_broken_door_event,
    _play_slow_elevator_event,
    #_play_vip_event,
]


func _ready() -> void:
    _setup_timer_for_next_event()


func _setup_timer_for_next_event() -> void:
    var time_before_next_event: float = randf_range(MIN_WINDOW, MAX_WINDOW)
    _timer.start(time_before_next_event)


func _on_timer_timeout() -> void:
    event_function.pick_random().call()
    _setup_timer_for_next_event()


func _play_broken_door_event() -> void:
    pass


func _play_slow_elevator_event() -> void:
    game_manager.elevator.set_broken_speed_to(true)
    game_manager._narrative_manager.update_message(BROKEN_ELEVATOR_MESSAGE)
    
    await get_tree().create_timer(TIME_BEFORE_TECH_GUY).timeout
    
    var tech_guy: bool = true
    game_manager._spawn_npc(tech_guy)
    

func _play_vip_event() -> void:
    pass
