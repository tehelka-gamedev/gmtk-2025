class_name NPC
extends Node2D

@export var color: Enum.NPCColors = Enum.NPCColors.RED
@export var slot:Slot = null

## If true, will queue_free() after reaching its point
var exiting: bool = false

@onready var state_machine: StateMachine = $StateMachine
@onready var _skin: NPCSkin = $Pivot/Skin


func go_to_slot(s: Slot) -> void:
    slot = s
    if s == null:
        push_error("Tried to go to a none slot, something is wrong !")
        return
    state_machine.transition_to(
        NPCStatesUtil.StatesName.move_to,
        {
            NPCStatesUtil.Message.target: s
        }
    )

# called when exiting the room. For now just queue_free but add fade out later maybe
func exit() -> void:
    queue_free()
