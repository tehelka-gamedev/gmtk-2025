extends Control

@export var intro_scene: PackedScene = null

@export var button_play: Button = null
@export var button_credits: Button = null

@export var background_scroll_speed: float = 5.0
@export var _background: TextureRect = null

@export var fade_in_time: float = 2.0

func _ready() -> void:
    AudioManager.play_music(SoundBank.main_menu_music, fade_in_time)

    button_play.pressed.connect(func():
        get_tree().change_scene_to_packed(intro_scene)
    )


func _process(delta) -> void:
    (_background.texture as AtlasTexture).region.position.x += delta * background_scroll_speed