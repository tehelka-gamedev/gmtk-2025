@tool
extends RoomBase
class_name Room


@export_category("Gameplay variables")
@export var color: Enum.NPCColors = Enum.NPCColors.RED :
    set(value):
        if not is_node_ready():
            await ready
        color = value
        _decal.modulate = Enum.color_enum_to_rgb(color)


@export var entrance_position:Marker2D = null
@export var decal_to_use: bool = false:
    set(value):
        if not ready:
            await is_node_ready()
        decal_to_use = value
        if decal_to_use:
            _decal.region_rect.position.x = 124
        else:
            _decal.region_rect.position.x = 0

@onready var npc_spawn: Marker2D = $NPCSpawn
@onready var _door: Sprite2D = $Door
@onready var pivot: Node2D = $Pivot
@onready var _decal: Sprite2D = $Pivot/Decal


func get_spawn_point() -> Marker2D:
    return npc_spawn


func open_door() -> void:
    _door.hide()


func close_door() -> void:
    _door.show()

func get_entrance_position() -> Marker2D:
    return entrance_position
