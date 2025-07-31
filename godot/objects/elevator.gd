extends RoomBase
class_name Elevator

signal toggle_movement_requested

@export var speed: float = 200.0
@export var moving: bool = true

func _process(_delta) -> void:
    if Input.is_action_just_pressed("elevator_toggle_movement"):
        toggle_movement_requested.emit()
        moving = not moving
