@tool
extends RoomBase
class_name Elevator

signal left_door_opened
signal right_door_opened
signal toggle_movement_requested

@export var distance_to_pivot_point:float = 300 :
    set(value):
        distance_to_pivot_point = value
        if inner_pivot:
            print("move elevator")
            inner_pivot.position.x = distance_to_pivot_point

@export var speed: float = 2.0
@export var moving: bool = true
@export var snap_duration: float = 2.0


@export_category("Editor variables")
@export var inner_pivot:Node2D = null # Where the sprite and object actually is
@export var room_detector:Area2D = null
@export var look_at_helper:Node2D = null # used to help in rotation computation

@export_category("Debug")
@export var show_trajectory: bool = false :
    set(value):
        show_trajectory = value

var _snapping: bool = false
var _tween: Tween = null

func _ready() -> void:
    if not room_detector:
        push_error("No room detector in elevator!")
        return
    if not inner_pivot:
        push_error("No inner pivot in elevator!")
        return
    if not look_at_helper:
        push_error("No look_at_helper in elevator!")
        return
    
    room_detector.body_entered.connect(_on_body_entered)

    

func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        _process_editor()
    else:
        _process_game(delta)

func _process_editor() -> void:
    queue_redraw()

func _process_game(delta: float) -> void:
    if Input.is_action_just_pressed("elevator_toggle_movement"):
        toggle_movement_requested.emit()
        moving = not moving

    if not moving:
        if Input.is_action_just_pressed("open_left_door"):
            # play open_left_door_animation
            # await open_left_door_animation.finished
            left_door_opened.emit()
        elif Input.is_action_just_pressed("open_right_door"):
            # play open_right_door_animation
            # await open_right_door_animation.finished
            right_door_opened.emit()
    
    if _snapping:
        return
    if moving:
        rotation_degrees -= delta * speed

func _draw():
    if Engine.is_editor_hint():
        if show_trajectory:
            var filled:bool = false
            draw_circle(Vector2.ZERO, distance_to_pivot_point, Color.RED, filled)

func _on_body_entered(body: Node2D):
    print("BODY ! %s" % body)
    snap_to_room(body)

# for now, just typehint Node2D since we actually give the PhysicsBody2D and not the room...
func snap_to_room(room: Node2D) -> void:
    _snapping = true
    moving = false
    look_at_helper.look_at(room.global_position)
    var target_rotation:float = look_at_helper.global_rotation

    if rotation < 0:
        target_rotation -= 2*PI

    print("From %s to %s !" % [rotation, target_rotation])



    _tween = get_tree().create_tween()
    _tween.tween_property(self, "rotation", target_rotation, snap_duration)
    _tween.set_trans(Tween.TRANS_ELASTIC)
    _tween.set_ease(Tween.EASE_IN)

    _tween.finished.connect(_on_snap_finished)

func _on_snap_finished() -> void:
    print("Snap finished!")
