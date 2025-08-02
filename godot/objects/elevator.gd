@tool
extends RoomBase
class_name Elevator

signal door_opened
signal door_closed
signal snapped_to_room(room:Node2D)
signal toggle_movement_requested

@export var DOOR_COYOTE_THRESHOLD: float = 1.0
@export var distance_to_pivot_point:float = 60.0 :
    set(value):
        distance_to_pivot_point = value
        if inner_pivot:
            inner_pivot.position.x = distance_to_pivot_point

@export var speed_array: Array[float] = [30.0, 60.0, 90.0, 150.0, 360.0]
@export var current_speed: int = 2
@export var moving: bool = true
@export var snap_duration: float = 0.5
@export var snap_target:Node2D = null

@export var space_station: SpaceStation

var door_is_open: bool = false

@export_category("Editor variables")
@export var inner_pivot:Node2D = null # Where the sprite and object actually is
@export var room_detector:Area2D = null
@export var look_at_helper:Node2D = null # used to help in rotation computation
@export var entrance_position:Marker2D = null

@export_category("Debug")
@export var show_trajectory: bool = false :
    set(value):
        show_trajectory = value



var _snapping: bool = false
var _snapped: bool = false
var _tween: Tween = null
var _people_are_entering: bool = false
var _door_coyote_time: float = 0.0
var _door_coyote_flag: bool = false

@onready var _door: Sprite2D = $Door


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
    room_detector.body_exited.connect(_on_body_exited)

    

func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        _process_editor()
    else:
        _process_game(delta)

func _process_editor() -> void:
    queue_redraw()

func _process_game(delta: float) -> void:
    # only can toggle movement if doors are closed
    if Input.is_action_just_pressed("elevator_toggle_movement"):
        handle_toggle_movement()
            
    elif _snapping:
        _refresh_tween()

    if Input.is_action_just_pressed("open_door"):
        _handle_open_door()
    
    if moving and not _snapping:
        rotation_degrees -= delta * speed_array[current_speed]
    else:
        rotation_degrees += space_station.rotation_speed * delta
    
    if _door_coyote_flag:
        _door_coyote_time += delta
        if _door_coyote_time >= DOOR_COYOTE_THRESHOLD:
            _handle_open_door()
            _door_coyote_time = 0.0
            _door_coyote_flag = false


func _open_door() -> void:
    # play open_door_animation
    # await open__door_animation.finished
    door_is_open = true
    _door.hide()
    snap_target.open_door()
    door_opened.emit()

func _close_door() -> void:
    door_is_open = false
    _door.show()
    snap_target.close_door()
    door_closed.emit()

func _draw():
    if Engine.is_editor_hint():
        if show_trajectory:
            var filled:bool = false
            draw_circle(Vector2.ZERO, distance_to_pivot_point, Color.RED, filled)

func _on_body_entered(body: Node2D):
    # UGLY HACK: refer to the grand-parent room, and fallback to the staticBody2D otherwise
    # Would need to find a better way for that...
    snap_target = body.find_parent("Room*")
    if snap_target == null:
        snap_target = body


func _on_body_exited(body: Node2D):
    var target = body.find_parent("Room*")
    target = target if target else body
    if target == snap_target:
        snap_target = null

# for now, just typehint Node2D since we actually give the PhysicsBody2D and not the room...
func snap_to_room() -> void:
    _snapping = true
    moving = false
    _refresh_tween()


func _refresh_tween() -> void:
    if not snap_target:
        return
    
    look_at_helper.look_at(snap_target.global_position)
    var target_rotation:float = look_at_helper.global_rotation

    target_rotation = lerp_angle(rotation, target_rotation, 1)
    if abs(target_rotation - rotation) < 0.001:
        _on_snap_finished()
        return
    if _tween:
        _tween.stop()
    _tween = get_tree().create_tween()
    _tween.tween_property(self, "rotation", target_rotation, snap_duration)
    _tween.set_trans(Tween.TRANS_ELASTIC)
    _tween.set_ease(Tween.EASE_IN)

    _tween.finished.connect(_on_snap_finished)


func stop_snapping() -> void:
    _tween.stop()
    _tween = null
    _snapping = false


func _on_snap_finished() -> void:
    snapped_to_room.emit(snap_target)
    _snapped = true
    stop_snapping()


func get_snapped_room() -> Room:
    return snap_target as Room if snap_target else null


func handle_toggle_movement() -> void:
    if door_is_open:
        return
    
    toggle_movement_requested.emit()

    # if snapping, we can abort and leave
    if _snapping:
        stop_snapping()
        moving = true

    # otherwise, if we can snap
    elif snap_target:
        # we start snapping if we move, otherwise that is we are already stopped
        if moving:
            snap_to_room()
        else:
            if _snapped:
                _snapped = false
            moving = true
    # else just regular start/stop
    else:
        if _snapped:
            _snapped = false
        moving = not moving

func on_speed_value_changed(value: int) -> void:
    if value != current_speed:
        current_speed = value


func on_open_gates() -> void:
    if door_is_open:
        return
    _handle_open_door()


func on_close_gates() -> void:
    if not door_is_open:
        return
    _handle_open_door()


func on_start_elevator() -> void:
    if moving:
        return
    handle_toggle_movement()


func on_stop_elevator() -> void:
    if not moving:
        return
    handle_toggle_movement()


func get_entrance_position() -> Marker2D:
    return entrance_position

# Called when people start entering
func start_loading_people() -> void:
    _people_are_entering = true

func stop_loading_people() -> void:
    _people_are_entering = false


func _handle_open_door() -> void:
    if _snapped and not _people_are_entering:
        if door_is_open:
            _close_door()
        else:
            _open_door()
    elif not _door_coyote_flag and (_snapping or _people_are_entering):
        _door_coyote_flag = true
