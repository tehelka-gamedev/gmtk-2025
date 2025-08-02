extends Node2D
class_name MoodGauge

enum MoodState
{
    ANGRY,          # >:( 
    IMPATIENT,      # :|
    HAPPY,          # :D
}

static func mood_to_state(mood: float) -> MoodState:
    if mood <= 15:
        return MoodState.ANGRY
    elif mood <= 50:
        return MoodState.IMPATIENT
    else:
        return MoodState.HAPPY

static func state_to_mood(state: MoodState) -> float:
    match state:
        MoodState.ANGRY:
            return 15.0
        MoodState.IMPATIENT:
            return 50.0
        MoodState.HAPPY:
            return 100.0
        _:
            push_error("Unknow state '%s' in state_to_mood" % state)
            return 0.0


signal mood_value_changed(new_value:float)
signal mood_state_changed(old_mood: MoodState, new_mood: MoodState)

@export var current_mood_value: float = 100.0
## Regen per regen ticks
@export var regen_per_tick: float = 1.0
## Variance in the regen. Must be a NON-NEGATIVE number. If set to X
##, the regen will be regen_per tick +/- variance
@export var variance_regen: float = 0.0

## minimum 1
@export var tick_between_regen: int = 1
@export var min_value: int = 0
@export var max_value: int = 100

var _mood_state: MoodState = MoodState.HAPPY
var _tick_counter = 0


func _process(delta: float) -> void:
    _tick_counter = (_tick_counter + 1) % tick_between_regen

    if _tick_counter != 0:
        return
    
    set_mood_value(current_mood_value + _get_random_regen_per_tick() * delta)


## returns the regen per tick with the eventual variance taken into account
func _get_random_regen_per_tick() -> float:
    return regen_per_tick + randf_range(-variance_regen, variance_regen)


func set_mood_value(new_mood_value: float, _emit_signal: bool = true) -> void:
    var old_value: float = current_mood_value
    var old_state: MoodState = _mood_state
    current_mood_value = clampf(new_mood_value, min_value, max_value)

    if not is_equal_approx(old_value, current_mood_value):
        _mood_state = mood_to_state(current_mood_value)
        if _emit_signal:
            mood_value_changed.emit(current_mood_value)
        if old_state != _mood_state and _emit_signal:
            mood_state_changed.emit(old_state, _mood_state)

func set_mood_state(new_state: MoodState, _emit_signal: bool = true) -> void:
    set_mood_value(state_to_mood(new_state), _emit_signal)
