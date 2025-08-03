extends State


@export var MOVE_SPEED: int = 7

var current_position: Marker2D


func process(_delta: float) -> void:
    owner.global_position = current_position.global_position


func enter(msg: = {}) -> void:
    current_position = msg.get(NPCStatesUtil.Message.target)[0]
    var despawn_target: Array[Node2D] = [msg.get(NPCStatesUtil.Message.target)[1]]
    owner.on_repair_finished.connect(
        func():
            owner.exiting = true
            owner.state_machine.transition_to(NPCStatesUtil.StatesName.move_to, {NPCStatesUtil.Message.target: despawn_target}
        )
    )
