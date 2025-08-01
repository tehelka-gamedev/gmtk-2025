class_name SpaceStation
extends Sprite2D


@export var rotation_speed: float = 3.0


func _physics_process(delta: float) -> void:
    rotation_degrees += delta * rotation_speed
