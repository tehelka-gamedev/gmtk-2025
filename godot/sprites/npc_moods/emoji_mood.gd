extends Node2D
class_name EmojiMood

@export var emoji_angry: CompressedTexture2D = null
@export var emoji_grumpy: CompressedTexture2D = null
@export var emoji_bored: CompressedTexture2D = null
@export var emoji_calm: CompressedTexture2D = null
@export var emoji_happy: CompressedTexture2D = null

@export_category("Editor variables")
@export var sprite: Sprite2D = null
@export var animation_player: AnimationPlayer = null

# if briefly, play the animation to fade out and queue_free
# if briefly is false, the caller is responbile of the life time of this object!!
func set_mood(mood: MoodGauge.MoodState, briefly: bool = true) -> void:
    match mood:
        MoodGauge.MoodState.ANGRY:
            sprite.texture = emoji_angry
        MoodGauge.MoodState.GRUMPY:
            sprite.texture = emoji_grumpy
        MoodGauge.MoodState.BORED:
            sprite.texture = emoji_bored
        MoodGauge.MoodState.CALM:
            sprite.texture = emoji_calm
        MoodGauge.MoodState.HAPPY:
            sprite.texture = emoji_happy
        _:
            push_error("Trying to set a mood but no emoji set with it!! Default to HAPPY :)")
            sprite.texture = emoji_happy

    if briefly:
        animation_player.play("fade_out_moving_up")