extends Node2D

@export var elevator: Elevator = null
@export var path_follow: PathFollow2D = null
@export var rooms: Array[Room] = []

func _ready() -> void:
	if elevator == null:
		push_error("no elevator")
		return
	
	if path_follow == null:
		push_error("no path follow")
		return
	
func _process(delta) -> void:
	# This part could be in a script of pathFollow2D probably...
	if elevator.moving:
		path_follow.progress += delta * elevator.speed
