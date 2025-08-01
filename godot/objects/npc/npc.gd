class_name NPC
extends Node2D

@export var _skin: NPCSkin
@export var color: Enum.NPCColors = Enum.NPCColors.RED:
    set(value):
        color = value
        if not is_node_ready():
            await ready
        _skin.set_color_to(Enum.color_enum_to_rgb(color))
@export var slot:Slot = null

## If true, will queue_free() after reaching its point
var exiting: bool = false

@onready var state_machine: StateMachine = $StateMachine


func go_to_slot(s: Slot) -> void:
    slot = s
    if s == null:
        push_error("Tried to go to a none slot, something is wrong !")
        return
    var targets:Array[Node2D] = [s]
    state_machine.transition_to(
        NPCStatesUtil.StatesName.move_to,
        {
            NPCStatesUtil.Message.target: targets
        }
    )

# called when exiting the room. For now just queue_free but add fade out later maybe
func exit() -> void:
    queue_free()
