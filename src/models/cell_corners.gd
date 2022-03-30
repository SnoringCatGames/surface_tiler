class_name CellCorners
extends Reference


var top_left := SubtileCorner.UNKNOWN
var top_right := SubtileCorner.UNKNOWN
var bottom_left := SubtileCorner.UNKNOWN
var bottom_right := SubtileCorner.UNKNOWN

var external_tl_t := SubtileCorner.UNKNOWN
var external_tl_l := SubtileCorner.UNKNOWN
var external_tr_t := SubtileCorner.UNKNOWN
var external_tr_r := SubtileCorner.UNKNOWN
var external_bl_b := SubtileCorner.UNKNOWN
var external_bl_l := SubtileCorner.UNKNOWN
var external_br_b := SubtileCorner.UNKNOWN
var external_br_r := SubtileCorner.UNKNOWN

var external_tl_t2 := SubtileCorner.UNKNOWN
var external_tl_l2 := SubtileCorner.UNKNOWN
var external_tr_t2 := SubtileCorner.UNKNOWN
var external_tr_r2 := SubtileCorner.UNKNOWN
var external_bl_b2 := SubtileCorner.UNKNOWN
var external_bl_l2 := SubtileCorner.UNKNOWN
var external_br_b2 := SubtileCorner.UNKNOWN
var external_br_r2 := SubtileCorner.UNKNOWN


func _init(proximity: CellProximity) -> void:
    self.top_left = St.corner_calculator \
            .get_target_top_left_corner(proximity)
    self.top_right = St.corner_calculator \
            .get_target_top_right_corner(proximity)
    self.bottom_left = St.corner_calculator \
            .get_target_bottom_left_corner(proximity)
    self.bottom_right = St.corner_calculator \
            .get_target_bottom_right_corner(proximity)
    
    if proximity.get_is_present(0, -1):
        var top_proximity := CellProximity.new(
                proximity.tile_map,
                proximity.tile,
                proximity.position + Vector2(0, -1))
        self.external_tl_t = \
                St.corner_calculator \
                    .get_target_bottom_left_corner(top_proximity)
        self.external_tr_t = \
                St.corner_calculator \
                    .get_target_bottom_right_corner(top_proximity)
        self.external_tl_t2 = \
                St.corner_calculator \
                    .get_target_top_left_corner(top_proximity)
        self.external_tr_t2 = \
                St.corner_calculator \
                    .get_target_top_right_corner(top_proximity)
    else:
        self.external_tl_t = SubtileCorner.EMPTY
        self.external_tr_t = SubtileCorner.EMPTY
        self.external_tl_t2 = SubtileCorner.EMPTY
        self.external_tr_t2 = SubtileCorner.EMPTY
    
    if proximity.get_is_present(0, 1):
        var bottom_proximity := CellProximity.new(
                proximity.tile_map,
                proximity.tile,
                proximity.position + Vector2(0, 1))
        self.external_bl_b = \
                St.corner_calculator \
                    .get_target_top_left_corner(bottom_proximity)
        self.external_br_b = \
                St.corner_calculator \
                    .get_target_top_right_corner(bottom_proximity)
        self.external_bl_b2 = \
                St.corner_calculator \
                    .get_target_bottom_left_corner(bottom_proximity)
        self.external_br_b2 = \
                St.corner_calculator \
                    .get_target_bottom_right_corner(bottom_proximity)
    else:
        self.external_bl_b = SubtileCorner.EMPTY
        self.external_br_b = SubtileCorner.EMPTY
        self.external_bl_b2 = SubtileCorner.EMPTY
        self.external_br_b2 = SubtileCorner.EMPTY
    
    if proximity.get_is_present(-1, 0):
        var left_proximity := CellProximity.new(
                proximity.tile_map,
                proximity.tile,
                proximity.position + Vector2(-1, 0))
        self.external_tl_l = \
                St.corner_calculator \
                    .get_target_top_right_corner(left_proximity)
        self.external_bl_l = \
                St.corner_calculator \
                    .get_target_bottom_right_corner(left_proximity)
        self.external_tl_l2 = \
                St.corner_calculator \
                    .get_target_top_left_corner(left_proximity)
        self.external_bl_l2 = \
                St.corner_calculator \
                    .get_target_bottom_left_corner(left_proximity)
    else:
        self.external_tl_l = SubtileCorner.EMPTY
        self.external_bl_l = SubtileCorner.EMPTY
        self.external_tl_l2 = SubtileCorner.EMPTY
        self.external_bl_l2 = SubtileCorner.EMPTY
    
    if proximity.get_is_present(1, 0):
        var right_proximity := CellProximity.new(
                proximity.tile_map,
                proximity.tile,
                proximity.position + Vector2(1, 0))
        self.external_tr_r = \
                St.corner_calculator \
                    .get_target_top_left_corner(right_proximity)
        self.external_br_r = \
                St.corner_calculator \
                    .get_target_bottom_left_corner(right_proximity)
        self.external_tr_r2 = \
                St.corner_calculator \
                    .get_target_top_right_corner(right_proximity)
        self.external_br_r2 = \
                St.corner_calculator \
                    .get_target_bottom_right_corner(right_proximity)
    else:
        self.external_tr_r = SubtileCorner.EMPTY
        self.external_br_r = SubtileCorner.EMPTY
        self.external_tr_r2 = SubtileCorner.EMPTY
        self.external_br_r2 = SubtileCorner.EMPTY


func get_corner_type(
        corner_direction: int,
        connection_direction := ConnectionDirection.SELF) -> int:
    match [corner_direction, connection_direction]:
        [CornerDirection.TOP_LEFT, ConnectionDirection.SELF]:
            return top_left
        [CornerDirection.TOP_LEFT, ConnectionDirection.H_INTERNAL]:
            return top_right
        [CornerDirection.TOP_LEFT, ConnectionDirection.V_INTERNAL]:
            return bottom_left
        [CornerDirection.TOP_LEFT, ConnectionDirection.D_INTERNAL]:
            return bottom_right
        [CornerDirection.TOP_LEFT, ConnectionDirection.H_EXTERNAL]:
            return external_tl_l
        [CornerDirection.TOP_LEFT, ConnectionDirection.H2_EXTERNAL]:
            return external_tl_l2
        [CornerDirection.TOP_LEFT, ConnectionDirection.HD_EXTERNAL]:
            return external_bl_l
        [CornerDirection.TOP_LEFT, ConnectionDirection.HD2_EXTERNAL]:
            return external_bl_l2
        [CornerDirection.TOP_LEFT, ConnectionDirection.V_EXTERNAL]:
            return external_tl_t
        [CornerDirection.TOP_LEFT, ConnectionDirection.V2_EXTERNAL]:
            return external_tl_t2
        [CornerDirection.TOP_LEFT, ConnectionDirection.VD_EXTERNAL]:
            return external_tr_t
        [CornerDirection.TOP_LEFT, ConnectionDirection.VD2_EXTERNAL]:
            return external_tr_t2
        
        [CornerDirection.TOP_RIGHT, ConnectionDirection.SELF]:
            return top_right
        [CornerDirection.TOP_RIGHT, ConnectionDirection.H_INTERNAL]:
            return top_left
        [CornerDirection.TOP_RIGHT, ConnectionDirection.V_INTERNAL]:
            return bottom_right
        [CornerDirection.TOP_RIGHT, ConnectionDirection.D_INTERNAL]:
            return bottom_left
        [CornerDirection.TOP_RIGHT, ConnectionDirection.H_EXTERNAL]:
            return external_tr_r
        [CornerDirection.TOP_RIGHT, ConnectionDirection.H2_EXTERNAL]:
            return external_tr_r2
        [CornerDirection.TOP_RIGHT, ConnectionDirection.HD_EXTERNAL]:
            return external_br_r
        [CornerDirection.TOP_RIGHT, ConnectionDirection.HD2_EXTERNAL]:
            return external_br_r2
        [CornerDirection.TOP_RIGHT, ConnectionDirection.V_EXTERNAL]:
            return external_tr_t
        [CornerDirection.TOP_RIGHT, ConnectionDirection.V2_EXTERNAL]:
            return external_tr_t2
        [CornerDirection.TOP_RIGHT, ConnectionDirection.VD_EXTERNAL]:
            return external_tl_t
        [CornerDirection.TOP_RIGHT, ConnectionDirection.VD2_EXTERNAL]:
            return external_tl_t2
        
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.SELF]:
            return bottom_left
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.H_INTERNAL]:
            return bottom_right
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.V_INTERNAL]:
            return top_left
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.D_INTERNAL]:
            return top_right
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.H_EXTERNAL]:
            return external_bl_l
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.H2_EXTERNAL]:
            return external_bl_l2
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.HD_EXTERNAL]:
            return external_tl_l
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.HD2_EXTERNAL]:
            return external_tl_l2
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.V_EXTERNAL]:
            return external_bl_b
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.V2_EXTERNAL]:
            return external_bl_b2
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.VD_EXTERNAL]:
            return external_br_b
        [CornerDirection.BOTTOM_LEFT, ConnectionDirection.VD2_EXTERNAL]:
            return external_br_b2
        
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.SELF]:
            return bottom_right
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.H_INTERNAL]:
            return bottom_left
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.V_INTERNAL]:
            return top_right
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.D_INTERNAL]:
            return top_left
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.H_EXTERNAL]:
            return external_br_r
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.H2_EXTERNAL]:
            return external_br_r2
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.HD_EXTERNAL]:
            return external_tr_r
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.HD2_EXTERNAL]:
            return external_tr_r2
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.V_EXTERNAL]:
            return external_br_b
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.V2_EXTERNAL]:
            return external_br_b2
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.VD_EXTERNAL]:
            return external_bl_b
        [CornerDirection.BOTTOM_RIGHT, ConnectionDirection.VD2_EXTERNAL]:
            return external_bl_b2
        
        _:
            Sc.logger.error("CellCorners.get_corner_type")
            return SubtileCorner.UNKNOWN


func to_string(uses_newlines := false) -> String:
    var corner_strings := []
    for connection_direction in ConnectionDirection.DISTINCT_CONNECTIONS:
        var connection_direction_string := \
                ConnectionDirection.get_string(connection_direction)
        for corner_direction in CornerDirection.CORNERS:
            var corner_type := \
                    get_corner_type(corner_direction, connection_direction)
            var corner_direction_string := \
                    CornerDirection.get_string(corner_direction)
            var corner_type_string: String = \
                    St.get_subtile_corner_string(corner_type)
            corner_strings.push_back("%s-%s=%s" % [
                    corner_direction_string,
                    connection_direction_string,
                    corner_type_string,
               ])
    if uses_newlines:
        return "CellCorners(\n    %s\n)" % \
                Sc.utils.join(corner_strings, ",\n    ")
    else:
        return "CellCorners(%s)" % Sc.utils.join(corner_strings, ", ")


func get_are_corners_valid() -> bool:
    for connection_direction in ConnectionDirection.DISTINCT_CONNECTIONS:
        for corner_direction in CornerDirection.CORNERS:
            var corner_type := \
                    get_corner_type(corner_direction, connection_direction)
            if corner_type == SubtileCorner.ERROR or \
                    corner_type == SubtileCorner.UNKNOWN:
                return false
    return true
