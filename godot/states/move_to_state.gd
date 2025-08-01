extends State
# This state allows to go to a target node
# When transitionning to this state, need a msg = {targets:Array[TargetReference]} !
# This is an array [A, B, C] where the npc goes to A.position, then when arrived, to B.position
# then to C.position and target C.position until otherwise.

const MOVE_SPEED:int = 5

var _targets: Array[Node2D] = []
var _arrived: bool = false

func process(delta: float) -> void:
    if len(_targets) == 0:
        push_error("'%s' trying to move to targets but there is none!" % name)
        return
    var next_target_pos:Vector2 = _targets[0].global_position
    owner.global_position = (
            next_target_pos if _arrived
            else lerp(owner.global_position, next_target_pos, delta * MOVE_SPEED)
    )
    if owner.global_position.distance_squared_to(next_target_pos) < 10:
        # One target left, we arrived, yay! :D
        if len(_targets) == 1:
            _arrived = true
            if owner.exiting:
                owner.exit()
        if len(_targets) > 1:
            _targets.remove_at(0) # remove first element, ugly, but enough for jam

func enter(msg: = {}) -> void:
    _targets = msg.get(NPCStatesUtil.Message.target)
    _arrived = false
    
func exit(_msg: = {}) -> void:
    _targets = []
    _arrived = false
