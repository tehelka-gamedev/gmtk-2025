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
    const alpha: float = 0.9
    match col:
        NPCColors.RED:
            return Color(1, 0, 0, alpha)
        NPCColors.BLUE:
            return Color(0, 0, 1, alpha)
        NPCColors.PINK:
            return Color(0.8, 0.05, 0.8, alpha)
        NPCColors.ORANGE:
            return Color(0.8, 0.45, 0.05, alpha)
        NPCColors.GREEN:
            return Color(0, 1, 0, alpha)
        NPCColors.YELLOW:
            return Color(0.922, 0.906, 0.0, alpha)
        _:
            return Color.WHITE
