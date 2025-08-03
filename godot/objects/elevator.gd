extends RoomBase
class_name Elevator

signal door_opened
signal door_closed
signal snapped_to_room(room:Node2D)
signal toggle_movement_requested
signal speed_changed(new_speed:int, speed_idx:int)
signal broken_speed_changed(broken: bool)

const SNAP_LERP_VALUE: float = 5.0

@export var DOOR_COYOTE_THRESHOLD: float = 1.0
@export var distance_to_pivot_point:float = 60.0 :
    set(value):
        distance_to_pivot_point = value
        if inner_pivot:
            inner_pivot.position.x = distance_to_pivot_point

@export var speed_array: Array[float] = [30.0, 60.0, 90.0, 150.0, 360.0]
@export var current_speed: int = 2 :
    set(value):
        value = clamp(value, 0, len(speed_array)-1)
        if value != current_speed:
            current_speed = value
            speed_changed.emit(speed_array[current_speed], current_speed)

@export var moving: bool = true
@export var snap_duration: float = 0.5
@export var snap_target:Node2D = null

@export var space_station: SpaceStation

@export_category("Editor variables")
@export var inner_pivot:Node2D = null # Where the sprite and object actually is
@export var room_detector:Area2D = null
@export var entrance_position:Marker2D = null

var _snapping: bool = false
var _snapped: bool = false
var _people_are_entering: bool = false
var broken_speed: bool = false

# door states
enum DoorState {
    CLOSED,
    OPENED,
    OPENING,
    CLOSING
}
var _current_door_state: DoorState = DoorState.CLOSED

@onready var _door: AnimatedSprite2D = $Door
@onready var _broken_speed_particles: CPUParticles2D = $BrokenSpeedParticles

func door_is_open() -> bool:
    return _current_door_state == DoorState.OPENED

func door_is_closed() -> bool:
    return _current_door_state == DoorState.CLOSED

func door_is_closing() -> bool:
    return _current_door_state == DoorState.CLOSING

func door_is_opening() -> bool:
    return _current_door_state == DoorState.OPENING

func set_door_open() -> void:
    _current_door_state = DoorState.OPENED
    _door.play("open")
    await _door.animation_finished
    door_opened.emit()

func set_door_closed() -> void:
    _current_door_state = DoorState.CLOSED
    _door.play("close")
    await _door.animation_finished
    door_closed.emit()



#### DOOR END  ####


func _ready() -> void:
    if not room_detector:
        push_error("No room detector in elevator!")
        return
    if not inner_pivot:
        push_error("No inner pivot in elevator!")
        return
    
    room_detector.body_entered.connect(_on_body_entered)
    room_detector.body_exited.connect(_on_body_exited)

    door_closed.connect(_on_door_closed)
    _broken_speed_particles.emitting = false


func _process(delta: float) -> void:
    # if Input.is_action_just_pressed("open_door"):
    # doors have priority

    # only can toggle movement if doors are closed
    if Input.is_action_just_pressed("elevator_toggle_movement"):
        handle_toggle_movement()
    elif _snapping:
        _handle_snapping(delta)
    
    if moving and not _snapping:
        rotation_degrees -= delta * speed_array[current_speed]
    else:
        rotation_degrees += space_station.rotation_speed * delta


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("increase_elevator_speed"):
        if not broken_speed:
            current_speed += 1
    elif event.is_action_pressed("decrease_elevator_speed"):
        if not broken_speed:
            current_speed -= 1

func _open_door() -> void:
    _current_door_state = DoorState.OPENING
    get_tree().create_timer(0.5).timeout.connect(set_door_open) # Temporary wait, for animation later
    # play open_door_animation
    # await open__door_animation.finished
    
    snap_target.open_door()

func _close_door() -> void:
    _current_door_state = DoorState.CLOSING
    get_tree().create_timer(0.5).timeout.connect(set_door_closed) # Temporary wait, for animation later
    
    snap_target.close_door()

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


func _handle_snapping(delta: float) -> void:
    var target_rotation: float = inner_pivot.position.normalized().angle_to((snap_target.pivot.global_position - global_position).normalized())
    target_rotation = lerp_angle(rotation, target_rotation, 1)
    
    var snaping_factor = speed_array[current_speed] / speed_array[2]
    
    rotation = lerp_angle(rotation, target_rotation, min(delta * SNAP_LERP_VALUE * snaping_factor, 1.0))
    if abs(target_rotation - rotation) < 0.01:
        rotation = target_rotation
        _on_snap_finished()


func _on_snap_finished() -> void:
    snapped_to_room.emit(snap_target)
    _snapped = true
    _snapping = false

    _open_door()


func get_snapped_room() -> Room:
    return snap_target as Room if _snapped else null


func handle_toggle_movement() -> void:
    if _people_are_entering:
        return
    
    if door_is_closing() or door_is_opening():
        return

    if door_is_open():
        _close_door()
        return

    toggle_movement_requested.emit()

    # if snapping, we can abort and leave
    if _snapping:
        _snapping = false
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

func set_speed_idx_no_signal(value: int) -> void:
    current_speed = value

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

func _on_door_closed() -> void:
    # go back agaiiiiin
    handle_toggle_movement()


func set_broken_speed_to(value: bool) -> void:
    broken_speed = value
    if broken_speed:
        current_speed = 0
        _broken_speed_particles.emitting = true
    else:
        current_speed = 2
        _broken_speed_particles.emitting = false
    broken_speed_changed.emit(value)
        
