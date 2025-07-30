extends Node
class_name State

@onready var _state_machine := _get_state_machine(self)

var _parent: State = null

func _ready() -> void:
	var parent := get_parent()
	if parent is State:
		_parent = parent

func unhandled_input(event: InputEvent) -> void:
	pass
	
func process(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass

func enter(msg: = {}) -> void:
	pass
	
func exit(msg: = {}) -> void:
	pass

func _get_state_machine(node: Node) -> Node:
	if node != null and not node is StateMachine:
		return _get_state_machine(node.get_parent())
	else:
		return node
