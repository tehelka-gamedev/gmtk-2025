extends HBoxContainer

@export var check_button: CheckButton = null
@export var small_light: SmallLight = null

func _ready():
    if check_button == null:
        push_error("No button found in %s" % name)
        return
    
    if small_light == null:
        push_error("No small light found in %s" % name)
        return
    
    refresh_light(check_button.button_pressed)

    check_button.toggled.connect(refresh_light)


func refresh_light(toggled_on: bool) -> void:
    small_light.set_template(
        SmallLight.LightTemplate.OK if toggled_on
        else SmallLight.LightTemplate.NOT_OK
    )

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_jingle"):
        check_button.button_pressed = not check_button.button_pressed
        