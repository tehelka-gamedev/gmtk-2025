extends Node2D
class_name EmojiMood

signal animation_finished

const anim_default: String = "default"
const anim_angry: String = "angry"
const anim_impatient: String = "impatient"

@export_category("Gameplay variables")
@export var timeout_delay: int = 5

@export_category("Editor variables")
@export var animated_sprite: AnimatedSprite2D = null

# if briefly, queue_free after X seconds
# if briefly is false, the caller is responbile of the life time of this object!!
func set_mood(mood: MoodGauge.MoodState, briefly: bool = true) -> void:
    match mood:
        MoodGauge.MoodState.ANGRY:
            animated_sprite.play(anim_angry)
        MoodGauge.MoodState.IMPATIENT:
            animated_sprite.play(anim_impatient)
        MoodGauge.MoodState.HAPPY:
            animated_sprite.play(anim_default)
        _:
            push_error("Trying to set a mood but no emoji set with it!! Default to nothing :)")
            animated_sprite.play(anim_default)

    if briefly:
        get_tree().create_timer(timeout_delay).timeout.connect(func():
            animation_finished.emit()
            queue_free()
        )
