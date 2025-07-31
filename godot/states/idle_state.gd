extends State
# This states do nothing (for now)

func process(delta: float) -> void:
	pass

func enter(msg: = {}) -> void:
	print("Entering Idle State, msg=%s" %msg)
	
func exit(msg: = {}) -> void:
	print("Exiting Idle State")