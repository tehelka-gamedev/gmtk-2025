class_name NPCSkin
extends Node2D

enum Orientation {DOWN = 0, RIGHT = 1, LEFT = 2, UP = 3}

const WIDTH: int = 16
const HEIGHT: int = 16

const CHARACTER_HEADS: Texture2D = preload("res://sprites/characterheads.png")
const CHARACTER_BODY: Texture2D = preload("res://sprites/Clothes.png")

@onready var _head: Sprite2D = $Head
@onready var _body: Sprite2D = $Body

var body_type_number: int = int(CHARACTER_BODY.get_width() / WIDTH)
var head_color_number_w: int = int(CHARACTER_HEADS.get_width() / WIDTH) / body_type_number
var head_color_number_h: int = int(CHARACTER_HEADS.get_height() / HEIGHT) / 4

var body_type_idx: int = 0
var head_type_x: int = 0
var head_type_y: int = 0

func _ready() -> void:
    body_type_idx = randi_range(0, body_type_number - 1)
    _body.region_rect.position.x = WIDTH * body_type_idx
    _body.region_rect.end.x = WIDTH * (body_type_idx + 1)
    
    head_type_x = randi_range(0, head_color_number_w - 1)
    head_type_y = randi_range(0, head_color_number_h - 1)
    set_orientation_to(NPCSkin.Orientation.DOWN)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_right"):
        set_orientation_to(NPCSkin.Orientation.RIGHT)
    elif event.is_action_pressed("ui_left"):
        set_orientation_to(NPCSkin.Orientation.LEFT)
    elif event.is_action_pressed("ui_up"):
        set_orientation_to(NPCSkin.Orientation.UP)
    elif event.is_action_pressed("ui_down"):
        set_orientation_to(NPCSkin.Orientation.DOWN)


func set_color_to(color: Color) -> void:
    _body.modulate = color


func set_orientation_to(orientation: NPCSkin.Orientation) -> void:
    _head.region_rect.position.x = (CHARACTER_HEADS.get_width() / head_color_number_w) * head_type_x + WIDTH * body_type_idx
    _head.region_rect.position.y = (CHARACTER_HEADS.get_height() / head_color_number_h) * head_type_y + HEIGHT * orientation
    _body.region_rect.position.y = HEIGHT * orientation
    
    
