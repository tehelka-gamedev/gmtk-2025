extends MarginContainer

@export var button:Button = null
@export var small_light: SmallLight = null

func _ready():
    if button == null:
        push_error("No button found in %s" % name)
        return
    
    if small_light == null:
        push_error("No small light found in %s" % name)
        return

    button.pressed.connect(_on_button_pressed)
    
    var is_muted = AudioManager.is_se_muted()
    refresh_light(is_muted)

    AudioManager.SE_mute_state_changed.connect(
        func(_is_muted: bool):
            refresh_light(_is_muted)
    )


func _on_button_pressed() -> void:
    # toggle SE
    var new_mute_state: bool = not AudioManager.is_se_muted()
    AudioManager.mute_se(new_mute_state)

    refresh_light(new_mute_state)
    
func refresh_light(muted: bool) -> void:
    small_light.set_template(
        SmallLight.LightTemplate.NOT_OK if muted
        else SmallLight.LightTemplate.OK
    )
