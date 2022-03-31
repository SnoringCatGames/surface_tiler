class_name SubtileCornerToDepth
extends Reference


# FIXME: LEFT OFF HERE: -------------- Remove all of the obsolete depth-based stuff?


const CORNERS_TO_DEPTHS := {
    SubtileCorner.UNKNOWN: SubtileDepth.UNKNOWN,
    
    SubtileCorner.ERROR: SubtileDepth.UNKNOWN,
    SubtileCorner.EMPTY: SubtileDepth.UNKNOWN,
    SubtileCorner.FULLY_INTERIOR: SubtileDepth.FULLY_INTERIOR,
    
    ### 90-degree.
    
    SubtileCorner.EXT_90H: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_90V: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_90_90_CONVEX: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_90_90_CONCAVE: SubtileDepth.EXTERIOR,
    
    SubtileCorner.EXT_INT_90H: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90V: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90_90_CONVEX: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90_90_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90H: SubtileDepth.INT_EXT,
    SubtileCorner.INT_90V: SubtileDepth.INT_EXT,
    SubtileCorner.INT_90_90_CONVEX: SubtileDepth.INT_EXT,
    SubtileCorner.INT_90_90_CONCAVE: SubtileDepth.INT_EXT,
    
    ### 45-degree.
    
    SubtileCorner.EXT_45_H_SIDE: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_45_V_SIDE: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_EXT_45_CLIPPED: SubtileDepth.EXTERIOR,
    
    SubtileCorner.EXT_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_45_CLIPPED: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_EXT_45_CLIPPED: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_45_H_SIDE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_45_V_SIDE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_45_CLIPPED: SubtileDepth.INT_EXT,
    
    ### 90-to-45-degree.
    
    SubtileCorner.EXT_90H_45_CONVEX_ACUTE: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_90V_45_CONVEX_ACUTE: SubtileDepth.EXTERIOR,
    
    SubtileCorner.EXT_90H_45_CONVEX: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_90V_45_CONVEX: SubtileDepth.EXTERIOR,
    
    SubtileCorner.EXT_EXT_90H_45_CONCAVE: SubtileDepth.EXTERIOR,
    SubtileCorner.EXT_EXT_90V_45_CONCAVE: SubtileDepth.EXTERIOR,
    
    SubtileCorner.EXT_INT_90H_45_CONVEX: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90V_45_CONVEX: SubtileDepth.EXT_INT,
    
    SubtileCorner.EXT_INT_90H_45_CONCAVE: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_EXT_90H_45_CONCAVE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_EXT_90V_45_CONCAVE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_EXT_90V_45_CONCAVE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_90H_45_CONCAVE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_90V_45_CONCAVE: SubtileDepth.INT_EXT,
    
    ### Complex 90-45-degree combinations.
    
    SubtileCorner.EXT_INT_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    
    SubtileCorner.EXT_INT_90H_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90V_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_45_FLOOR_45_CEILING: SubtileDepth.INT_EXT,
    
    SubtileCorner.EXT_INT_90H_45_CONVEX_ACUTE: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90V_45_CONVEX_ACUTE: SubtileDepth.EXT_INT,
    
    SubtileCorner.EXT_INT_90H_45_CONVEX_ACUTE_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    SubtileCorner.EXT_INT_90V_45_CONVEX_ACUTE_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90H_EXT_INT_45_CONVEX_ACUTE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_EXT_INT_45_CONVEX_ACUTE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90H_EXT_INT_90H_45_CONCAVE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_EXT_INT_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.EXT_INT_90H_45_CONCAVE_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    
    
    SubtileCorner.INT_90H_INT_EXT_45_CLIPPED: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_INT_EXT_45_CLIPPED: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONVEX_INT_EXT_45_CLIPPED: SubtileDepth.EXT_INT,
    
    
    SubtileCorner.INT_90H_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONVEX_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    
    
    SubtileCorner.INT_90H_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONVEX_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90H_INT_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_INT_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONVEX_INT_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_90H_INT_INT_EXT_90V_45_CONCAVE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_90V_INT_INT_EXT_90H_45_CONCAVE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_H_SIDE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_V_SIDE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_V_SIDE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_H_SIDE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_H_SIDE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_V_SIDE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_45_FLOOR_45_CEILING: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_45_FLOOR_45_CEILING: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_90V_45_CONCAVE_INT_45_FLOOR_45_CEILING: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_INT_90H_45_CONCAVE_90V_45_CONCAVE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_90H_45_CONCAVE_INT_45_V_SIDE: SubtileDepth.INT_EXT,
    SubtileCorner.INT_INT_90V_45_CONCAVE_INT_45_H_SIDE: SubtileDepth.INT_EXT,
    
    SubtileCorner.INT_90H_INT_INT_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_INT_INT_90H_45_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_INT_EXT_90H_45_CONCAVE_INT_INT_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_INT_EXT_90V_45_CONCAVE_INT_INT_90H_45_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90H_INT_INT_90V_45_CONCAVE_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90V_INT_INT_90H_45_CONCAVE_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90_90_CONCAVE_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONCAVE_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONCAVE_INT_45_FLOOR_45_CEILING: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONCAVE_INT_INT_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_90V_45_CONCAVE: SubtileDepth.EXT_INT,
    
    SubtileCorner.INT_90_90_CONCAVE_INT_INT_90H_45_CONCAVE_INT_45_V_SIDE: SubtileDepth.EXT_INT,
    SubtileCorner.INT_90_90_CONCAVE_INT_INT_90V_45_CONCAVE_INT_45_H_SIDE: SubtileDepth.EXT_INT,
    
    ### 27-degree.
    
    # FIXME: LEFT OFF HERE: ------------------
    
#    SubtileCorner.EXT_27_SHALLOW_CLIPPED: SubtileDepth.,
#    SubtileCorner.EXT_27_STEEP_CLIPPED: SubtileDepth.,
#
#    SubtileCorner.EXT_27_FLOOR_SHALLOW_CLOSE: SubtileDepth.,
#    SubtileCorner.EXT_27_FLOOR_SHALLOW_FAR: SubtileDepth.,
#    SubtileCorner.EXT_27_FLOOR_STEEP_CLOSE: SubtileDepth.,
#    SubtileCorner.EXT_27_FLOOR_STEEP_FAR: SubtileDepth.,
#
#    SubtileCorner.EXT_27_CEILING_SHALLOW_CLOSE: SubtileDepth.,
#    SubtileCorner.EXT_27_CEILING_SHALLOW_FAR: SubtileDepth.,
#    SubtileCorner.EXT_27_CEILING_STEEP_CLOSE: SubtileDepth.,
#    SubtileCorner.EXT_27_CEILING_STEEP_FAR: SubtileDepth.,
#
#
#    SubtileCorner.INT_27_INT_CORNER_SHALLOW: SubtileDepth.,
#    SubtileCorner.INT_27_INT_CORNER_STEEP: SubtileDepth.,
    
    
    ### 90-to-27-degree.
    
    # FIXME: LEFT OFF HERE: ------------------
    
    ### 45-to-27-degree.
    
    # FIXME: LEFT OFF HERE: ------------------
}
