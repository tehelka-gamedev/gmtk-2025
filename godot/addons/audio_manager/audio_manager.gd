@tool # Necessary to select the buses names in the editor
extends Node

# AudioManager
# A simple audio manager for Godot 4.x that handles background music (BGM)
# and sound effects (SE) using audio buses.

# Add a way to handle the sound bank? Another plugin?

#### Signals
## Signal emitted when the BGM mute state changes
signal BGM_mute_state_changed(is_muted:bool)
## Signal emitted when the SE mute state changes
signal SE_mute_state_changed(is_muted:bool)

@export_range(0, 100, 1) var default_bgm_volume: int = 100
@export_range(0, 100, 1) var bgm_volume_during_VA: int = 20

@export_category("Plugin settings")
## Bus name for background music (BGM)
@export var bgm_bus_name:String = "BGM" # Custom property, see _validate_property() for more info
## Bus name for sound effects (SE)
@export var se_bus_name:String = "SE" # Custom property, see _validate_property() for more info

## Whether the music is currently fading (in or out)
var _fading:bool = false
## Tween used for fading in/out music
var _tween:Tween = null

## BGM and SE bus index
@onready var BGM_bus_index:int = AudioServer.get_bus_index(bgm_bus_name)
@onready var SE_bus_index:int = AudioServer.get_bus_index(se_bus_name)
## AudioStreamPlayer used for background music
@onready var _music_player : AudioStreamPlayer = $MusicPlayer

func _ready():
    _music_player.bus = bgm_bus_name
    set_bgm_volume(default_bgm_volume)

#### Public API ####
func play_music(stream:AudioStream, fade_in_time:float=0.25) -> void:
    # If the same music is already playing, don't do anything
    if _music_player.stream == stream:
        return

    if _music_player.playing and not _fading:
        await fade_out_music(0.5)
    elif _music_player.playing and _fading:
        _tween.kill()
        _fading = false
    _music_player.stream = stream
    if fade_in_time > 0:
        _music_player.volume_db = AudioServer.get_bus_volume_db(BGM_bus_index) - 100
    _music_player.play()
    if fade_in_time > 0:
        _tween = get_tree().create_tween()
        _fading = true
        _tween.tween_property(_music_player, "volume_db", AudioServer.get_bus_volume_db(BGM_bus_index), fade_in_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
        await _tween.finished
        _fading = false

func play_sound_effect(stream:AudioStream) -> AudioStreamPlayer:
    var sound_player:AudioStreamPlayer = AudioStreamPlayer.new()
    sound_player.stream = stream
    sound_player.bus = se_bus_name
    sound_player.finished.connect(sound_player.queue_free)
    add_child(sound_player)
    sound_player.play()
    return sound_player

func music_is_playing() -> bool:
    return _music_player.playing

func stop_music() -> void:
    _music_player.stop()
    _music_player.stream = null

func fade_out_music(duration:float = 1.5) -> void:
    _tween = get_tree().create_tween()
    _fading = true
    _tween.tween_property(_music_player, "volume_db", -100, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

    await _tween.finished
    stop_music()
    _fading = false

## Set BGM bus volume
## (volume: 0-100)
func set_bgm_volume(volume:float) -> void:
    AudioServer.set_bus_volume_db(BGM_bus_index, linear_to_db(volume/100))

## Set SE bus volume
## (volume: 0-100)
func set_se_volume(volume:float) -> void:
    AudioServer.set_bus_volume_db(SE_bus_index, linear_to_db(volume/100))

func mute_bgm(is_muted:bool)	-> void:
    var was_muted:bool = AudioServer.is_bus_mute(BGM_bus_index)

    AudioServer.set_bus_mute(BGM_bus_index, is_muted)
    if was_muted != is_muted:
        BGM_mute_state_changed.emit(is_muted)

func mute_se(is_muted:bool)	-> void:
    var was_muted:bool = AudioServer.is_bus_mute(SE_bus_index)

    AudioServer.set_bus_mute(SE_bus_index, is_muted)
    if was_muted != is_muted:
        SE_mute_state_changed.emit(is_muted)
    
func is_bgm_muted() -> bool:
    return AudioServer.is_bus_mute(BGM_bus_index)

func is_se_muted() -> bool:
    return AudioServer.is_bus_mute(SE_bus_index)


######### Property List #########
# Exported properties are used to set the bus names in the editor

func _get_all_bus_names() -> Array[String]:
    var bus_names:Array[String] = []
    for i in range(AudioServer.get_bus_count()):
        bus_names.append(AudioServer.get_bus_name(i))
    return bus_names

func _validate_property(property: Dictionary):
    if property.name == "bgm_bus_name":
        var bus_names:Array[String] = _get_all_bus_names()
        property.hint = PROPERTY_HINT_ENUM
        property.hint_string = ",".join(bus_names)
        if not bus_names.has(bgm_bus_name):
            bgm_bus_name = bus_names[0] if bus_names.size() > 0 else "Master"
    elif property.name == "se_bus_name":
        var bus_names:Array[String] = _get_all_bus_names()
        property.hint = PROPERTY_HINT_ENUM
        property.hint_string = ",".join(bus_names)
        if not bus_names.has(se_bus_name):
            se_bus_name = bus_names[0] if bus_names.size() > 0 else "Master"

func _property_can_revert(property : StringName) -> bool:
    # Bus names revert to "Master" if not set
    return property == "bgm_bus_name" or property == "se_bus_name"

func _property_get_revert(property):
    if property == "bgm_bus_name" or property == "se_bus_name":
        return "Master"
    return null
