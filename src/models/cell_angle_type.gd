class_name CellAngleType


enum {
    UNKNOWN,
    EMPTY,
    A90 = 90,
    A45 = 45,
    A27 = 27,
}


static func get_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        EMPTY:
            return "EMPTY"
        A90:
            return "A90"
        A45:
            return "A45"
        A27:
            return "A27"
        _:
            Sc.logger.error("CellAngleType.get_string")
            return "??"
