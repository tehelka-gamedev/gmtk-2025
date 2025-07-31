extends RoomBase
class_name Elevator

signal left_door_opened
signal right_door_opened
signal toggle_movement_requested

@export var speed: float = 200.0
@export var moving: bool = true

func _process(_delta) -> void:
	if Input.is_action_just_pressed("elevator_toggle_movement"):
		toggle_movement_requested.emit()
		moving = not moving


func _unhandled_input(event: InputEvent) -> void:
	if not moving:
		if event.is_action_pressed("open_left_door"):
			# play open_left_door_animation
			# await open_left_door_animation.finished
			left_door_opened.emit()
		elif event.is_action_pressed("open_right_door"):
			# play open_right_door_animation
			# await open_right_door_animation.finished
			right_door_opened.emit()
		
