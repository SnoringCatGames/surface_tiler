class_name CornerDirection


enum {
    UNKNOWN,
    TOP_LEFT,
    TOP_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_RIGHT,
}

const CORNERS := [
    TOP_LEFT,
    TOP_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_RIGHT,
]


static func get_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        TOP_LEFT:
            return "TOP_LEFT"
        TOP_RIGHT:
            return "TOP_RIGHT"
        BOTTOM_LEFT:
            return "BOTTOM_LEFT"
        BOTTOM_RIGHT:
            return "BOTTOM_RIGHT"
        _:
            Sc.logger.error("CornerDirection.get_string")
            return "??"


static func get_is_top(type: int) -> bool:
    match type:
        UNKNOWN:
            return false
        TOP_LEFT, \
        TOP_RIGHT:
            return true
        BOTTOM_LEFT, \
        BOTTOM_RIGHT:
            return false
        _:
            Sc.logger.error("CornerDirection.get_is_top")
            return false


static func get_is_left(type: int) -> bool:
    match type:
        UNKNOWN:
            return false
        TOP_LEFT, \
        BOTTOM_LEFT:
            return true
        TOP_RIGHT, \
        BOTTOM_RIGHT:
            return false
        _:
            Sc.logger.error("CornerDirection.get_is_left")
            return false


static func get_horizontal_flip(corner_direction: int) -> int:
    match corner_direction:
        TOP_LEFT:
            return TOP_RIGHT
        BOTTOM_LEFT:
            return BOTTOM_RIGHT
        TOP_RIGHT:
            return TOP_LEFT
        BOTTOM_RIGHT:
            return BOTTOM_LEFT
        UNKNOWN:
            return UNKNOWN
        _:
            Sc.logger.error("CornerDirection.get_horizontal_flip")
            return UNKNOWN


static func get_vertical_flip(corner_direction: int) -> int:
    match corner_direction:
        TOP_LEFT:
            return BOTTOM_LEFT
        BOTTOM_LEFT:
            return TOP_LEFT
        TOP_RIGHT:
            return BOTTOM_RIGHT
        BOTTOM_RIGHT:
            return TOP_RIGHT
        UNKNOWN:
            return UNKNOWN
        _:
            Sc.logger.error("CornerDirection.get_vertical_flip")
            return UNKNOWN
