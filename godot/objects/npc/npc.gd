class_name NPC
extends Node2D

@export var color: Enum.NPCColors = Enum.NPCColors.RED
@export var slot:Slot = null

@onready var state_machine: StateMachine = $StateMachine

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