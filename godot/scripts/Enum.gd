@tool
extends Node
# must be autoload Enum !

enum NPCColors {
    RED,
    GREEN,
    PINK,
    ORANGE,
    BLUE,
    YELLOW
}

func color_enum_to_rgb(col: NPCColors) -> Color:
    match col:
        NPCColors.RED:
            return Color(1, 0, 0, 0.5)
        NPCColors.BLUE:
            return Color(0, 0, 1, 0.5)
        NPCColors.PINK:
            return Color(0.8, 0.05, 0.8, 0.5)
        NPCColors.ORANGE:
            return Color(0.8, 0.45, 0.05, 0.5)
        NPCColors.GREEN:
            return Color(0, 1, 0, 0.5)
        NPCColors.YELLOW:
            return Color(0.922, 0.906, 0.0, 0.502)
        _:
            return Color.WHITE
