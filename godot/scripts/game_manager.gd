extends Node2D

const NPC_class = preload("res://objects/npc/npc.tscn")

@export var starting_npc_count: int = 5
@export var elevator: Elevator = null
@export var path_follow: PathFollow2D = null

@onready var rooms: Array[Node] = $Rooms.get_children()
@onready var _npcs: Node2D = $NPCs

var current_npc_count: int = 0


func _ready() -> void:
	if elevator == null:
		push_error("no elevator")
		return
	
	if path_follow == null:
		push_error("no path follow")
		return
	
	for i in range(starting_npc_count):
		_spawn_npc()


func _process(delta) -> void:
	# This part could be in a script of pathFollow2D probably...
	if elevator.moving:
		path_follow.progress += delta * elevator.speed


func _spawn_npc() -> void:
	var non_full_rooms: Array[Room] = []
	for room: RoomBase in rooms:
		if not room.slot_manager.is_full():
			non_full_rooms.append(room)
	
	var random_room: Room = non_full_rooms.pick_random()
	var spawn_position: Vector2 = random_room.npc_spawn.global_position
	var npc: NPC = NPC_class.instantiate()
	npc.position = spawn_position
	_npcs.add_child(npc)
	npc.state_machine.transition_to("MoveTo", {NPCStatesUtil.Message.target: random_room.slot_manager.get_first_available_slot()})
