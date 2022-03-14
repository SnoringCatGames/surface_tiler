class_name ConnectionDirection


enum {
    UNKNOWN,
    
    SELF,
    
    H_INTERNAL,
    V_INTERNAL,
    D_INTERNAL,
    
    H_EXTERNAL,
    HD_EXTERNAL,
    H2_EXTERNAL,
    HD2_EXTERNAL,
    
    V_EXTERNAL,
    VD_EXTERNAL,
    V2_EXTERNAL,
    VD2_EXTERNAL,
}

const CONNECTIONS := [
    SELF,
    
    H_INTERNAL,
    V_INTERNAL,
    D_INTERNAL,
    
    H_EXTERNAL,
    V_EXTERNAL,
    
    H2_EXTERNAL,
    V2_EXTERNAL,
    
    HD_EXTERNAL,
    VD_EXTERNAL,
    
    HD2_EXTERNAL,
    VD2_EXTERNAL,
]

const CONNECTIONS_IN_QUADRANT_MATCH_PRIORITY_ORDER := [
    SELF,
    
    H_INTERNAL,
    V_INTERNAL,
    
    H_EXTERNAL,
    V_EXTERNAL,
    
    D_INTERNAL,
    
    HD_EXTERNAL,
    VD_EXTERNAL,
    
    H2_EXTERNAL,
    V2_EXTERNAL,
    
    HD2_EXTERNAL,
    VD2_EXTERNAL,
]

const DISTINCT_CONNECTIONS := [
    SELF,
    
    H_EXTERNAL,
    V_EXTERNAL,
    
    H2_EXTERNAL,
    V2_EXTERNAL,
]


static func get_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        SELF:
            return "SELF"
        H_INTERNAL:
            return "H_INTERNAL"
        V_INTERNAL:
            return "V_INTERNAL"
        D_INTERNAL:
            return "D_INTERNAL"
        H_EXTERNAL:
            return "H_EXTERNAL"
        H2_EXTERNAL:
            return "H2_EXTERNAL"
        HD_EXTERNAL:
            return "HD_EXTERNAL"
        HD2_EXTERNAL:
            return "HD2_EXTERNAL"
        V_EXTERNAL:
            return "V_EXTERNAL"
        V2_EXTERNAL:
            return "V2_EXTERNAL"
        VD_EXTERNAL:
            return "VD_EXTERNAL"
        VD2_EXTERNAL:
            return "VD2_EXTERNAL"
        _:
            Sc.logger.error("ConnectionDirection.get_string")
            return "??"


static func get_is_top(
        corner_direction: int,
        connection_direction: int) -> bool:
    var is_corner_direction_top := \
            CornerDirection.get_is_top(corner_direction)
    var does_connection_direction_flip_top := \
            get_does_connection_direction_flip_top(connection_direction)
    return is_corner_direction_top != does_connection_direction_flip_top


static func get_is_left(
        corner_direction: int,
        connection_direction: int) -> bool:
    var is_corner_direction_left := \
            CornerDirection.get_is_left(corner_direction)
    var does_connection_direction_flip_left := \
            get_does_connection_direction_flip_left(connection_direction)
    return is_corner_direction_left != does_connection_direction_flip_left


static func get_does_connection_direction_flip_top(
        connection_direction: int) -> bool:
    return connection_direction == V_INTERNAL || \
            connection_direction == D_INTERNAL || \
            connection_direction == HD_EXTERNAL || \
            connection_direction == V_EXTERNAL || \
            connection_direction == VD_EXTERNAL || \
            connection_direction == HD2_EXTERNAL


static func get_does_connection_direction_flip_left(
        connection_direction: int) -> bool:
    return connection_direction == H_INTERNAL || \
            connection_direction == D_INTERNAL || \
            connection_direction == H_EXTERNAL || \
            connection_direction == HD_EXTERNAL || \
            connection_direction == VD_EXTERNAL || \
            connection_direction == VD2_EXTERNAL
