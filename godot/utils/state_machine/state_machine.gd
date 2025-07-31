extends Node
class_name StateMachine

signal transitioned(state_path)

@export var state: State = null:
	set(value):
		state = value
		state_name = state.name

var state_name := ""

func _ready() -> void:
	await owner.ready
	if state:
		state.enter()
		transitioned.emit(state_name)

func _unhandled_input(event: InputEvent) -> void:
	state.unhandled_input(event)

func _process(delta: float) -> void:
	state.process(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_process(delta)

func transition_to(target_state_path: String, msg: = {}) -> void:
	if not has_node(target_state_path):
		push_error("Non existant target state path: %s" % target_state_path)
		return
	var target_state := get_node(target_state_path)
	
	state.exit()
	self.state = target_state
	state.enter(msg)
	transitioned.emit(target_state_path)
	
