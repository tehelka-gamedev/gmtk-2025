extends Control


@export var game_scene: PackedScene = null

var va_sound: AudioStreamPlayer = null


func _ready() -> void:
    AudioManager.set_bgm_volume(AudioManager.bgm_volume_during_VA)
    va_sound = AudioManager.play_sound_effect(SoundBank.intro_bossletter)


func _on_button_pressed() -> void:
    if va_sound:
        va_sound.stop()
    AudioManager.set_bgm_volume(AudioManager.default_bgm_volume)
    get_tree().change_scene_to_packed(game_scene)
