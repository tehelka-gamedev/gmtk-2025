extends Marker2D
class_name Slot

signal reserved(slot: Slot)
signal released(slot: Slot)

@export var available: bool = true

# return true if could be reserved, false otherwise
func reserve() -> bool:
    if not available:
        push_error("Tried to reserve a slot (%s) that was not available!" % [name])
        return false
    available = false
    reserved.emit(self)
    return true

# return true if could be released, false otherwise
# false if was already available too
func release() -> bool:
    if available:
        push_error("Tried to release a slot (%s) that was already available!"% [name] )
        return false
    available = true
    released.emit(self)
    return true
