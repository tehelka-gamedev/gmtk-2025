@tool
extends CenterContainer
class_name SmallLight

enum LightTemplate {
    NEUTRAL,
    OK,
    NOT_OK
}

@export var template: LightTemplate = LightTemplate.NEUTRAL :
    set = set_template

@export var color: Color = Color.WHITE :
    set = set_color
@export var light: TextureRect = null

func set_color(col: Color) -> void:
    if not light:
        await ready
    color = col
    light.modulate = color

var _template_colors: Dictionary = {
    LightTemplate.NEUTRAL:  Color.WHITE,                        # normal white
    LightTemplate.OK:       Color(0.0, 0.698, 0.357, 0.953),    # greenish
    LightTemplate.NOT_OK:   Color(0.824, 0.129, 0.157, 0.953),  # redish
}
func set_template(temp: LightTemplate) -> void:
    template = temp
    var col: Color = _template_colors.get(temp, _template_colors[LightTemplate.NEUTRAL])
    set_color(col)