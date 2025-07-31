@tool
extends RoomBase
class_name Room

@export_category("Gameplay variables")
@export var color: Enum.NPCColors = Enum.NPCColors.RED :
    set(value):
        color = value
        modulate = Enum.color_enum_to_rgb(color)


@onready var npc_spawn: Marker2D = $NPCSpawn
