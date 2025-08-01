@tool
extends RoomBase
class_name Room

@export_category("Gameplay variables")
@export var color: Enum.NPCColors = Enum.NPCColors.RED :
    set(value):
        color = value
        modulate = Enum.color_enum_to_rgb(color)


@export var entrance_position:Marker2D = null

@onready var npc_spawn: Marker2D = $NPCSpawn
@onready var _door: Sprite2D = $Door


func get_spawn_point() -> Marker2D:
    return npc_spawn


func open_door() -> void:
    _door.hide()


func close_door() -> void:
    _door.show()

func get_entrance_position() -> Marker2D:
    return entrance_position