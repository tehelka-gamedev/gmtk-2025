extends State
# This state allows to go to a target node
# When transitionning to this state, need a msg = {target:TargetReference} !

var _target:Node2D = null

func process(delta: float) -> void:
    if not _target:
        push_error("'%s' trying to move to a target but there is none!" % name)
        return
    
    owner.global_position = lerp(owner.global_position, _target.global_position, delta * 5)
    

func enter(msg: = {}) -> void:
    _target = msg.get(NPCStatesUtil.Message.target)
    
func exit(msg: = {}) -> void:
    _target = null
