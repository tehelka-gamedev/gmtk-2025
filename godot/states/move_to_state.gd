extends State
# This state allows to go to a target node
# When transitionning to this state, need a msg = {target:TargetReference} !

var _target:Node2D = null

func process(delta: float) -> void:
    if not _target:
        push_error("'%s' trying to move to a target but there is none!" % name)
        return
    

func enter(msg: = {}) -> void:
    #print("Entering MoveTo State, msg=%s" %msg)
    _target = msg.get(NPCStatesUtil.Message.target)
    
func exit(msg: = {}) -> void:
    #print("Exiting MoveTo State")
    _target = null
