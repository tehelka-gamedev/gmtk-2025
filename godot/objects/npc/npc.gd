class_name NPC
extends Node2D

@warning_ignore("unused_signal")
signal arrived_at_slot

@export var _skin: NPCSkin
@export var color: Enum.NPCColors = Enum.NPCColors.RED:
    set(value):
        color = value
        if not is_node_ready():
            await ready
        _skin.set_color_to(Enum.color_enum_to_rgb(color))
@export var slot:Slot = null

@export_category("Editor variables")
@export var mood_gauge: MoodGauge = null
@export var emoji_position: Marker2D = null
@export var emoji_scene: PackedScene = null

## If true, will queue_free() after reaching its point
var exiting: bool = false

@onready var state_machine: StateMachine = $StateMachine
@onready var _teleport_animation: AnimatedSprite2D = $TeleportAnimation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    animation_player.play("spawn")
    if mood_gauge == null:
        return
    mood_gauge.set_mood_state(MoodGauge.MoodState.CALM, false)
    mood_gauge.mood_state_changed.connect(_on_mood_state_changed)


func _on_mood_state_changed(_old_mood_state: MoodGauge.MoodState, new_mood_state: MoodGauge.MoodState) -> void:
    var emoji: EmojiMood = emoji_scene.instantiate()
    emoji_position.add_child(emoji)

    var briefly: bool = new_mood_state != MoodGauge.MoodState.ANGRY
    emoji.set_mood(new_mood_state, briefly)



func go_to_slot(s: Slot) -> void:
    slot = s
    if s == null:
        push_error("Tried to go to a none slot, something is wrong !")
        return
    var targets:Array[Node2D] = [s]
    state_machine.transition_to(
        NPCStatesUtil.StatesName.move_to,
        {
            NPCStatesUtil.Message.target: targets
        }
    )

# called when exiting the room. For now just queue_free but add fade out later maybe
func exit() -> void:
    queue_free()
