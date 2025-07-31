extends Node
# must be autoload Enum !

enum NPCColors {
    RED,
    BLUE,
    GREEN,
    PINK,
    ORANGE
}

func color_enum_to_rgb(col: NPCColors) -> Color:
    match col:
        NPCColors.RED:
            return Color.RED
        NPCColors.BLUE:
            return Color.BLUE
        NPCColors.GREEN:
            return Color.GREEN
        NPCColors.PINK:
            return Color.PINK
        NPCColors.ORANGE:
            return Color.ORANGE

        _:
            return Color.WHITE

