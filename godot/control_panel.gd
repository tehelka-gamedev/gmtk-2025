extends Panel


signal open_gates_pressed
signal close_gates_pressed
signal start_elevator_pressed
signal stop_elevator_pressed
signal speed_cursor_changed(value: int)



@onready var speed_label: Label = %SpeedLabel
@onready var speed_slider: HSlider = %HSlider
@onready var message_panel: MessagePanel = %MessagePanel
@onready var angry_npc_label: Label = %AngryNPCLabel
@onready var conveyed_npc_label: Label = %ConveyedNPCLabel

func set_angry_npc_count(value: int) -> void:
    angry_npc_label.text = str(value)


func set_conveyed_npc_count(value: int) -> void:
    conveyed_npc_label.text = str(value)


func set_speed_cursor(value: int) -> void:
    update_speed_label(value)
    speed_slider.value = value

func _on_h_slider_value_changed(value: float) -> void:
    update_speed_label(int(value))
    speed_cursor_changed.emit(int(value)) #
        
func update_speed_label(speed_idx: int) -> void:
    speed_label.text = "Speed: %d" % (speed_idx+1)


func _on_start_button_pressed() -> void:
    start_elevator_pressed.emit()


func _on_stop_button_pressed() -> void:
    stop_elevator_pressed.emit()
