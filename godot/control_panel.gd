extends PanelContainer
class_name ControlPanel

signal toggle_elevator_movement
signal speed_cursor_changed(value: int)


@export var angry_npc_digit_display: DigitDisplay = null
@export var conveyed_npc_digit_display: DigitDisplay = null
@export var elevator_movement_lever: CheckButton = null
@export var speed_slider: HSlider = null

@onready var speed_label: Label = %SpeedLabel
@onready var message_panel: MessagePanel = %MessagePanel


func _ready() -> void:
    elevator_movement_lever.toggled.connect(_on_elevator_movement_lever_toggled)

func set_angry_npc_count(value: int) -> void:
    angry_npc_digit_display.set_value(value)


func set_conveyed_npc_count(value: int) -> void:
    conveyed_npc_digit_display.set_value(value)


func set_speed_cursor(value: int) -> void:
    update_speed_label(value)
    speed_slider.value = value


func _on_h_slider_value_changed(value: float) -> void:
    update_speed_label(int(value))
    speed_cursor_changed.emit(int(value))

        
func update_speed_label(speed_idx: int) -> void:
    speed_label.text = "Speed: %d" % (speed_idx+1)

func _on_elevator_movement_lever_toggled(_toggled_on: bool):
    toggle_elevator_movement.emit()

func _on_elevator_broken_set_to(broken: bool) -> void:
    if broken:
        speed_slider.editable = false
    else:
        speed_slider.editable = true
