extends Container
class_name MessagePanel

@export_category("Gameplay variables")
@export var MESSAGE_TIMER: float = 5.0

@export_category("Editor Variables")
@export var message_label: Label = null
@export var _message_timer: Timer = null

func _ready() -> void:
    _message_timer.timeout.connect(_on_message_timer_timeout)


func set_message(message: String) -> void:
    _message_timer.stop()
    message_label.text = message
    _message_timer.start(MESSAGE_TIMER)

func clear_message() -> void:
    message_label.text = ""

func _on_message_timer_timeout() -> void:
    clear_message()
