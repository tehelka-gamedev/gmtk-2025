extends PanelContainer
class_name DigitDisplay

const MIN_VAL:int = 0
const MAX_VAL:int = 99


@export_range(MIN_VAL, 99, 1) var value: int = 0 :
    set = set_value
@export var turned_on: bool = true :
    set(value):
        turned_on = value
        _refresh_textures()
@export var digit_color:Color = Color.WHITE :
    set(value):
        digit_color = value
        _refresh_color()

@export_category("Editor variables")
@export var first_digit_texture_rect: TextureRect = null
@export var second_digit_texture_rect: TextureRect = null

var _first_digit_atlas: AtlasTexture = null
var _second_digit_atlas: AtlasTexture = null

var _digit_sprite_size: Vector2 = Vector2.ZERO


func _ready() -> void:
    if not first_digit_texture_rect.get_texture() is AtlasTexture or not first_digit_texture_rect.get_texture() is AtlasTexture:
        push_error("Cannot use digit display, textures are not well defined")
    
    _first_digit_atlas = first_digit_texture_rect.get_texture() as AtlasTexture
    _second_digit_atlas = second_digit_texture_rect.get_texture() as AtlasTexture

    _digit_sprite_size = _first_digit_atlas.region.size
    _refresh_textures()
    
func set_value(val: int) -> void:
    val = clamp(val, 0, 99)
    value = val
    _refresh_textures()
    
  
func _set_texture_digit(texture: AtlasTexture, digit: int) -> void:
    texture.region.position.x = _digit_sprite_size.x * (digit+1)

func _turn_off_texture(texture: AtlasTexture) -> void:
    texture.region.position.x = 0

func _refresh_textures() -> void:
    if _first_digit_atlas == null:
        await ready
    

    @warning_ignore("integer_division")
    var tens: int = (value/10) % 10
    var units: int = value % 10

    print(tens, units)

    if turned_on:
        if tens > 0:
            _set_texture_digit(_first_digit_atlas, tens)
        else:
            _turn_off_texture(_first_digit_atlas)
        _set_texture_digit(_second_digit_atlas, units)
    else:
        _turn_off_texture(_first_digit_atlas)
        _turn_off_texture(_second_digit_atlas)

    

func _refresh_color() -> void:
    if first_digit_texture_rect == null:
        await ready
    
    first_digit_texture_rect.modulate = digit_color if turned_on else Color.WHITE
    second_digit_texture_rect.modulate = digit_color if turned_on else Color.WHITE
