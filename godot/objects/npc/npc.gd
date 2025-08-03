class_name NPC
extends Node2D

enum Type {NORMAL, TECH_GUY, VIP}

@warning_ignore("unused_signal")
signal arrived_at_slot
signal arrived_at_target_room
signal on_repair_finished

@export var _skin: NPCSkin
@export var color: Enum.NPCColors = Enum.NPCColors.RED:
    set(value):
        color = value
        if not is_node_ready():
            await ready
        _skin.set_color_to(Enum.color_enum_to_rgb(color))
@export var slot:Slot = null

@export_category("Gameplay variables")
## Will start with mood from between 100 and 100 - X
@export var mood_start_variation: float = 5.0

@export_category("Editor variables")
@export var mood_gauge: MoodGauge = null
@export var emoji_position: Marker2D = null
@export var emoji_scene: PackedScene = null


## If true, will queue_free() after reaching its point
var exiting: bool = false
var repairing: bool = false
var type: Type = Type.NORMAL

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    animation_player.play("spawn")
    if mood_gauge == null:
        return
    # mood_gauge.set_mood_state(MoodGauge.MoodState.HAPPY, false)
    mood_gauge.set_mood_value(MoodGauge.state_to_mood(MoodGauge.MoodState.HAPPY) - randf_range(0.0, mood_start_variation), false)
    mood_gauge.mood_state_changed.connect(_on_mood_state_changed)


func _on_mood_state_changed(_old_mood_state: MoodGauge.MoodState, new_mood_state: MoodGauge.MoodState) -> void:
    var emoji: EmojiMood = emoji_scene.instantiate()
    emoji_position.add_child(emoji)
    emoji.z_index = 2

    var briefly: bool = new_mood_state != MoodGauge.MoodState.ANGRY and new_mood_state != MoodGauge.MoodState.IMPATIENT
    emoji.set_mood(new_mood_state, briefly)



func go_to_slot(s: Slot) -> void:
    slot = s
    go_back_to_slot()

func go_back_to_slot() -> void:
    if slot == null:
        push_error("Tried to go to a none slot, something is wrong !")
        return
    var targets:Array[Node2D] = [slot]
    state_machine.transition_to(
        NPCStatesUtil.StatesName.move_to,
        {
            NPCStatesUtil.Message.target: targets
        }
    )

# called when exiting the room. For now just queue_free but add fade out later maybe
func exit() -> void:
    mood_gauge.set_mood_state(MoodGauge.MoodState.HAPPY)
    if not type == Type.TECH_GUY:
        arrived_at_target_room.emit()
    queue_free()


func set_color_directly(_color: Color) -> void:
    _skin.set_color_to(_color)


func repair() -> void:
    repairing = true
    var emoji: EmojiMood = emoji_scene.instantiate()
    emoji_position.add_child(emoji)
    emoji.z_index = 2
    
    var briefly: bool = true
    emoji.set_mood(MoodGauge.MoodState.IMPATIENT, briefly)
    await emoji.animation_finished
    repairing = false
    on_repair_finished.emit()


func show_type_label() -> void:
    if type == NPC.Type.TECH_GUY:
        %TypeLabel.text = "TECH"
    elif type == NPC.Type.VIP:
        %TypeLabel.text = "VIP"
    %TypeLabel.show()
