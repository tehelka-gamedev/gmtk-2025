extends Node
class_name State

@warning_ignore("unused_private_class_variable")
@onready var _state_machine := _get_state_machine(self)

var _parent: State = null

func _ready() -> void:
    var parent := get_parent()
    if parent is State:
        _parent = parent

func unhandled_input(_event: InputEvent) -> void:
    pass
    
func process(_delta: float) -> void:
    pass

func physics_process(_delta: float) -> void:
    pass

func enter(_msg: = {}) -> void:
    pass
    
func exit(_msg: = {}) -> void:
    pass

func _get_state_machine(node: Node) -> Node:
    if node != null and not node is StateMachine:
        return _get_state_machine(node.get_parent())
    else:
        return node
