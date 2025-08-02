extends Panel


signal open_gates_pressed
signal close_gates_pressed
signal start_elevator_pressed
signal stop_elevator_pressed
signal speed_cursor_changed(value: int)



@onready var speed_label: Label = %SpeedLabel
@onready var h_slider: HSlider = %HSlider
@onready var message_panel: MessagePanel = %MessagePanel
@onready var angry_npc_label: Label = %AngryNPCLabel
@onready var conveyed_npc_label: Label = %ConveyedNPCLabel


func set_speed_cursor(value: int) -> void:
    speed_label.text = "Speed: %d" % (value + 1)
    h_slider.value = value + 1


func set_angry_npc_count(value: int) -> void:
    angry_npc_label.text = str(value)


func set_conveyed_npc_count(value: int) -> void:
    conveyed_npc_label.text = str(value)


func _on_h_slider_value_changed(value: float) -> void:
    speed_label.text = "Speed: %d" % value
    speed_cursor_changed.emit(int(value - 1.0))


func _on_open_gates_pressed() -> void:
    open_gates_pressed.emit()


func _on_close_gates_pressed() -> void:
    close_gates_pressed.emit()


func _on_start_button_pressed() -> void:
    start_elevator_pressed.emit()


func _on_stop_button_pressed() -> void:
    stop_elevator_pressed.emit()
