class_name QuadrantShapeType


enum {
    EMPTY,
    
    FULL_SQUARE,
    CLIPPED_CORNER_90_90,
    CLIPPED_CORNER_45,
    MARGIN_TOP_90,
    MARGIN_SIDE_90,
    MARGIN_TOP_AND_SIDE_90,
    FLOOR_45_N,
    CEILING_45_N,
    EXT_90H_45_CONVEX_ACUTE,
    EXT_90V_45_CONVEX_ACUTE,
    
    FULL_SQUARE_CLIPPED_CORNER_45_OPP,
    CLIPPED_CORNER_90_90_CLIPPED_CORNER_45_OPP,
    CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP,
    MARGIN_TOP_90_CLIPPED_CORNER_45_OPP,
    MARGIN_SIDE_90_CLIPPED_CORNER_45_OPP,
}

const VALUES := [
    EMPTY,
    
    FULL_SQUARE,
    CLIPPED_CORNER_90_90,
    CLIPPED_CORNER_45,
    MARGIN_TOP_90,
    MARGIN_SIDE_90,
    MARGIN_TOP_AND_SIDE_90,
    FLOOR_45_N,
    CEILING_45_N,
    EXT_90H_45_CONVEX_ACUTE,
    EXT_90V_45_CONVEX_ACUTE,
    
    FULL_SQUARE_CLIPPED_CORNER_45_OPP,
    CLIPPED_CORNER_90_90_CLIPPED_CORNER_45_OPP,
    CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP,
    MARGIN_TOP_90_CLIPPED_CORNER_45_OPP,
    MARGIN_SIDE_90_CLIPPED_CORNER_45_OPP,
]

const _NEIGHBOR_TYPES_THAT_WOULD_CLIP_45 := {
    FLOOR_45_N: true,
    CEILING_45_N: true,
    EXT_90H_45_CONVEX_ACUTE: true,
    EXT_90V_45_CONVEX_ACUTE: true,
}


static func get_shape_type_for_corner_type(
        corner_type: int,
        h_internal_corner_type: int,
        v_internal_corner_type: int) -> int:
    var is_opposite_corner_clipped_45 := false
    if h_internal_corner_type != SubtileCorner.UNKNOWN and \
            v_internal_corner_type != SubtileCorner.UNKNOWN:
        var naive_shape_type_for_h_opp := get_shape_type_for_corner_type(
                h_internal_corner_type,
                SubtileCorner.UNKNOWN,
                SubtileCorner.UNKNOWN)
        var naive_shape_type_for_v_opp := get_shape_type_for_corner_type(
                v_internal_corner_type,
                SubtileCorner.UNKNOWN,
                SubtileCorner.UNKNOWN)
        if _NEIGHBOR_TYPES_THAT_WOULD_CLIP_45.has(
                    naive_shape_type_for_h_opp) or \
                _NEIGHBOR_TYPES_THAT_WOULD_CLIP_45.has(
                    naive_shape_type_for_v_opp):
            is_opposite_corner_clipped_45 = true
    
    if !is_opposite_corner_clipped_45:
        match corner_type:
            SubtileCorner.UNKNOWN:
                return FULL_SQUARE
            SubtileCorner.EMPTY:
                return EMPTY
            SubtileCorner.FULLY_INTERIOR:
                return FULL_SQUARE
            SubtileCorner.ERROR:
                return FULL_SQUARE
            
            ### 90-degree.
            
            SubtileCorner.EXT_90H:
                return MARGIN_TOP_90
            SubtileCorner.EXT_90V:
                return MARGIN_SIDE_90
            SubtileCorner.EXT_90_90_CONVEX:
                return MARGIN_TOP_AND_SIDE_90
            SubtileCorner.EXT_90_90_CONCAVE:
                return CLIPPED_CORNER_90_90
            
            SubtileCorner.EXT_INT_90H, \
            SubtileCorner.EXT_INT_90V, \
            SubtileCorner.EXT_INT_90_90_CONVEX, \
            SubtileCorner.EXT_INT_90_90_CONCAVE, \
            SubtileCorner.INT_90H, \
            SubtileCorner.INT_90V, \
            SubtileCorner.INT_90_90_CONVEX, \
            SubtileCorner.INT_90_90_CONCAVE:
                return FULL_SQUARE
            
            ### 45-degree.
            
            SubtileCorner.EXT_45_H_SIDE:
                return FLOOR_45_N
            SubtileCorner.EXT_45_V_SIDE:
                return CEILING_45_N
            SubtileCorner.EXT_EXT_45_CLIPPED:
                return CLIPPED_CORNER_45
            SubtileCorner.EXT_INT_45_CLIPPED:
                return FULL_SQUARE
            
            SubtileCorner.EXT_INT_45_H_SIDE, \
            SubtileCorner.EXT_INT_45_V_SIDE, \
            SubtileCorner.INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_45_H_SIDE, \
            SubtileCorner.INT_45_V_SIDE, \
            SubtileCorner.INT_INT_45_CLIPPED:
                return FULL_SQUARE
            
            ### 90-to-45-degree.
            
            SubtileCorner.EXT_90H_45_CONVEX_ACUTE:
                return EXT_90H_45_CONVEX_ACUTE
            SubtileCorner.EXT_90V_45_CONVEX_ACUTE:
                return EXT_90V_45_CONVEX_ACUTE
            
            SubtileCorner.EXT_90H_45_CONVEX:
                return MARGIN_TOP_90
            SubtileCorner.EXT_90V_45_CONVEX:
                return MARGIN_SIDE_90
            
            SubtileCorner.EXT_EXT_90H_45_CONCAVE:
                return CLIPPED_CORNER_45
            SubtileCorner.EXT_EXT_90V_45_CONCAVE:
                return CLIPPED_CORNER_45
            
            SubtileCorner.EXT_INT_90H_45_CONVEX, \
            SubtileCorner.EXT_INT_90V_45_CONVEX, \
            SubtileCorner.EXT_INT_90H_45_CONCAVE, \
            SubtileCorner.EXT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_EXT_90H_45_CONCAVE, \
            SubtileCorner.INT_EXT_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_90V_45_CONCAVE:
                return FULL_SQUARE
            
            ### Complex 90-45-degree combinations.
            
            SubtileCorner.EXT_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90H_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90V_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90H_45_CONVEX_ACUTE, \
            SubtileCorner.EXT_INT_90V_45_CONVEX_ACUTE, \
            SubtileCorner.EXT_INT_90H_45_CONVEX_ACUTE_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90V_45_CONVEX_ACUTE_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90H_EXT_INT_45_CONVEX_ACUTE, \
            SubtileCorner.INT_90V_EXT_INT_45_CONVEX_ACUTE, \
            SubtileCorner.INT_90H_EXT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_90V_EXT_INT_90V_45_CONCAVE, \
            SubtileCorner.EXT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90H_INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_90V_INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_90_90_CONVEX_INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_90H_INT_45_H_SIDE, \
            SubtileCorner.INT_90V_INT_45_H_SIDE, \
            SubtileCorner.INT_90_90_CONVEX_INT_45_H_SIDE, \
            SubtileCorner.INT_90H_INT_45_V_SIDE, \
            SubtileCorner.INT_90V_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONVEX_INT_45_V_SIDE, \
            SubtileCorner.INT_90H_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90V_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90_90_CONVEX_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90H_INT_INT_EXT_90V_45_CONCAVE, \
            SubtileCorner.INT_90V_INT_INT_EXT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_90H_INT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_90V_INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_90H_INT_INT_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_90V_INT_INT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90V_45_CONCAVE_INT_45_H_SIDE:
                return FULL_SQUARE
            
            # FIXME: LEFT OFF HERE: -------- A27
            
            _:
                Sc.logger.error(
                        ("QuadrantShapeType.get_shape_type_for_corner_type: " +
                        "%s, is_opposite_corner_clipped_45=%s") % [
                            St \
                                .get_subtile_corner_string(corner_type),
                            str(is_opposite_corner_clipped_45)
                        ])
                return FULL_SQUARE
        
    else:
        match corner_type:
            SubtileCorner.UNKNOWN:
                return FULL_SQUARE
            SubtileCorner.EMPTY:
                return EMPTY
            SubtileCorner.FULLY_INTERIOR:
                return FULL_SQUARE_CLIPPED_CORNER_45_OPP
            SubtileCorner.ERROR:
                return FULL_SQUARE
            
            ### 90-degree.
            
            SubtileCorner.EXT_90H:
                return MARGIN_TOP_90_CLIPPED_CORNER_45_OPP
            SubtileCorner.EXT_90V:
                return MARGIN_SIDE_90_CLIPPED_CORNER_45_OPP
            SubtileCorner.EXT_90_90_CONVEX:
                return MARGIN_TOP_AND_SIDE_90
            SubtileCorner.EXT_90_90_CONCAVE:
                return CLIPPED_CORNER_90_90_CLIPPED_CORNER_45_OPP
            
            SubtileCorner.EXT_INT_90H, \
            SubtileCorner.EXT_INT_90V, \
            SubtileCorner.EXT_INT_90_90_CONVEX, \
            SubtileCorner.EXT_INT_90_90_CONCAVE, \
            SubtileCorner.INT_90H, \
            SubtileCorner.INT_90V, \
            SubtileCorner.INT_90_90_CONVEX, \
            SubtileCorner.INT_90_90_CONCAVE:
                return FULL_SQUARE_CLIPPED_CORNER_45_OPP
            
            ### 45-degree.
            
            SubtileCorner.EXT_45_H_SIDE:
                return FLOOR_45_N
            SubtileCorner.EXT_45_V_SIDE:
                return CEILING_45_N
            SubtileCorner.EXT_EXT_45_CLIPPED:
                return CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP
            SubtileCorner.EXT_INT_45_CLIPPED:
                return FULL_SQUARE_CLIPPED_CORNER_45_OPP
            
            SubtileCorner.EXT_INT_45_H_SIDE, \
            SubtileCorner.EXT_INT_45_V_SIDE, \
            SubtileCorner.INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_45_H_SIDE, \
            SubtileCorner.INT_45_V_SIDE, \
            SubtileCorner.INT_INT_45_CLIPPED:
                return FULL_SQUARE_CLIPPED_CORNER_45_OPP
            
            ### 90-to-45-degree.
            
            SubtileCorner.EXT_90H_45_CONVEX_ACUTE:
                return EXT_90H_45_CONVEX_ACUTE
            SubtileCorner.EXT_90V_45_CONVEX_ACUTE:
                return EXT_90V_45_CONVEX_ACUTE
            
            SubtileCorner.EXT_90H_45_CONVEX:
                return MARGIN_TOP_90_CLIPPED_CORNER_45_OPP
            SubtileCorner.EXT_90V_45_CONVEX:
                return MARGIN_SIDE_90_CLIPPED_CORNER_45_OPP
            
            SubtileCorner.EXT_EXT_90H_45_CONCAVE:
                return CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP
            SubtileCorner.EXT_EXT_90V_45_CONCAVE:
                return CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP
            
            SubtileCorner.EXT_INT_90H_45_CONVEX, \
            SubtileCorner.EXT_INT_90V_45_CONVEX, \
            SubtileCorner.EXT_INT_90H_45_CONCAVE, \
            SubtileCorner.EXT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_EXT_90H_45_CONCAVE, \
            SubtileCorner.INT_EXT_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_90V_45_CONCAVE:
                return FULL_SQUARE_CLIPPED_CORNER_45_OPP
            
            ### Complex 90-45-degree combinations.
            
            SubtileCorner.EXT_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90H_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90V_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90H_45_CONVEX_ACUTE, \
            SubtileCorner.EXT_INT_90V_45_CONVEX_ACUTE, \
            SubtileCorner.EXT_INT_90H_45_CONVEX_ACUTE_45_FLOOR_45_CEILING, \
            SubtileCorner.EXT_INT_90V_45_CONVEX_ACUTE_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90H_EXT_INT_45_CONVEX_ACUTE, \
            SubtileCorner.INT_90V_EXT_INT_45_CONVEX_ACUTE, \
            SubtileCorner.INT_90H_EXT_INT_90H_45_CONCAVE, \
            SubtileCorner.EXT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90V_EXT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_90H_INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_90V_INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_90_90_CONVEX_INT_EXT_45_CLIPPED, \
            SubtileCorner.INT_90H_INT_45_H_SIDE, \
            SubtileCorner.INT_90V_INT_45_H_SIDE, \
            SubtileCorner.INT_90_90_CONVEX_INT_45_H_SIDE, \
            SubtileCorner.INT_90H_INT_45_V_SIDE, \
            SubtileCorner.INT_90V_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONVEX_INT_45_V_SIDE, \
            SubtileCorner.INT_90H_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90V_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90_90_CONVEX_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90H_INT_INT_EXT_90V_45_CONCAVE, \
            SubtileCorner.INT_90V_INT_INT_EXT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_INT_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_90H_INT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_90V_INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_90H_INT_INT_90V_45_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_90V_INT_INT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_45_H_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_45_FLOOR_45_CEILING, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90V_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_90V_45_CONCAVE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_INT_45_V_SIDE, \
            SubtileCorner.INT_90_90_CONCAVE_INT_INT_90V_45_CONCAVE_INT_45_H_SIDE:
                return FULL_SQUARE_CLIPPED_CORNER_45_OPP
            
            # FIXME: LEFT OFF HERE: -------- A27
            
            _:
                Sc.logger.error(
                        ("QuadrantShapeType.get_shape_type_for_corner_type: " +
                        "%s, is_opposite_corner_clipped_45=%s") % [
                            St \
                                .get_subtile_corner_string(corner_type),
                            str(is_opposite_corner_clipped_45)
                        ])
                return FULL_SQUARE
