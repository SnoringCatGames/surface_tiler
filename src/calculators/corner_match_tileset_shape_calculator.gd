tool
class_name CornerMatchTilesetShapeCalculator
extends Node


# Dictionary<
#   ("collision_shapes"|"occlusion_shapes"),
#   Dictionary<
#     CornerDirection,
#     Dictionary<
#       SubtileCorner, # Self-corner
#       Dictionary<
#         SubtileCorner, # H-internal-corner
#         Dictionary<
#           SubtileCorner, # V-internal-corner
#           (Shape2D|OccluderPolygon2D)>>>>>
func create_tileset_shapes(
        subtile_corner_types: Dictionary,
        tile: CornerMatchTile) -> Dictionary:
    # Use this to memoize and dedup shape instances.
    # Dictionary<
    #   QuadrantShapeType,
    #   Dictionary<
    #     CornerDirection,
    #     [Shape2D, OccluderPolygon2D]>>
    var shape_type_to_shapes := _create_shape_type_to_shapes(tile)
    
    # Dictionary<
    #   CornerDirection,
    #   Dictionary<
    #     SubtileCorner,
    #     Dictionary<
    #       SubtileCorner,
    #       Dictionary<
    #         SubtileCorner,
    #         Shape2D>>>>
    var collision_shapes := {}
    # Dictionary<
    #   CornerDirection,
    #   Dictionary<
    #     SubtileCorner,
    #     Dictionary<
    #       SubtileCorner,
    #       Dictionary<
    #         SubtileCorner,
    #         OccluderPolygon2D>>>>
    var occlusion_shapes := {}
    
    for corner_direction in subtile_corner_types:
        collision_shapes[corner_direction] = {}
        occlusion_shapes[corner_direction] = {}
        var self_corner_type_map: Dictionary = \
                subtile_corner_types[corner_direction]
        for self_corner_type in self_corner_type_map:
            collision_shapes[corner_direction][self_corner_type] = {}
            occlusion_shapes[corner_direction][self_corner_type] = {}
            var h_internal_corner_type_map_or_position = \
                    self_corner_type_map[self_corner_type]
            
            if h_internal_corner_type_map_or_position is Vector2:
                var h_internal_corner_type = SubtileCorner.UNKNOWN
                var v_internal_corner_type = SubtileCorner.UNKNOWN
                collision_shapes \
                        [corner_direction] \
                        [self_corner_type] \
                        [h_internal_corner_type] = {}
                occlusion_shapes \
                        [corner_direction] \
                        [self_corner_type] \
                        [h_internal_corner_type] = {}
                _record_shapes(
                        collision_shapes,
                        occlusion_shapes,
                        corner_direction,
                        self_corner_type,
                        h_internal_corner_type,
                        v_internal_corner_type,
                        shape_type_to_shapes)
                continue
            
            for h_internal_corner_type in h_internal_corner_type_map_or_position:
                collision_shapes \
                        [corner_direction] \
                        [self_corner_type] \
                        [h_internal_corner_type] = {}
                occlusion_shapes \
                        [corner_direction] \
                        [self_corner_type] \
                        [h_internal_corner_type] = {}
                var v_internal_corner_type_map_or_position = \
                        h_internal_corner_type_map_or_position[h_internal_corner_type]
                
                if v_internal_corner_type_map_or_position is Vector2:
                    var v_internal_corner_type = SubtileCorner.UNKNOWN
                    _record_shapes(
                            collision_shapes,
                            occlusion_shapes,
                            corner_direction,
                            self_corner_type,
                            h_internal_corner_type,
                            v_internal_corner_type,
                            shape_type_to_shapes)
                    continue
                
                for v_internal_corner_type in v_internal_corner_type_map_or_position:
                    _record_shapes(
                            collision_shapes,
                            occlusion_shapes,
                            corner_direction,
                            self_corner_type,
                            h_internal_corner_type,
                            v_internal_corner_type,
                            shape_type_to_shapes)
    
    return {
        collision_shapes = collision_shapes,
        occlusion_shapes = occlusion_shapes,
    }


func _record_shapes(
        collision_shapes: Dictionary,
        occlusion_shapes: Dictionary,
        corner_direction: int,
        self_corner_type: int,
        h_internal_corner_type: int,
        v_internal_corner_type: int,
        shape_type_to_shapes: Dictionary) -> void:
    var shape_type := QuadrantShapeType.get_shape_type_for_corner_type(
            self_corner_type,
            h_internal_corner_type,
            v_internal_corner_type)
    var shapes: Array = shape_type_to_shapes[shape_type][corner_direction]
    collision_shapes \
            [corner_direction] \
            [self_corner_type] \
            [h_internal_corner_type] \
            [v_internal_corner_type] = shapes[0]
    occlusion_shapes \
            [corner_direction] \
            [self_corner_type] \
            [h_internal_corner_type] \
            [v_internal_corner_type] = shapes[1]


# Dictionary<
#   QuadrantShapeType,
#   Dictionary<
#     CornerDirection,
#     Dictionary<
#       SubtileCorner,
#       [Array<Vector2>, Shape2D, OccluderPolygon2D]>>>
func _create_shape_type_to_shapes(tile: CornerMatchTile) -> Dictionary:
    var shape_type_to_shapes := {}
    
    for shape_type in QuadrantShapeType.VALUES:
        var corner_direction_to_shapes := {}
        shape_type_to_shapes[shape_type] = corner_direction_to_shapes
        
        for corner_direction in CornerDirection.CORNERS:
            var vertices := _get_shape_vertices(
                    shape_type,
                    corner_direction,
                    tile)
            
            var collision_shape: Shape2D
            var occlusion_shape: OccluderPolygon2D
            
            if !vertices.empty():
                var vertices_pool := PoolVector2Array(vertices)
                
                if St.forces_convex_collision_shapes or \
                        tile._config.subtile_collision_margin == 0.0:
                    collision_shape = ConvexPolygonShape2D.new()
                    collision_shape.points = vertices_pool
                else:
                    collision_shape = ConcavePolygonShape2D.new()
                    collision_shape.segments = vertices_pool
                
                occlusion_shape = OccluderPolygon2D.new()
                occlusion_shape.polygon = vertices_pool
            
            var shapes := [
                collision_shape,
                occlusion_shape,
            ]
            corner_direction_to_shapes[corner_direction] = shapes
    
    return shape_type_to_shapes


func _get_shape_vertices(
        shape_type: int,
        corner_direction: int,
        tile: CornerMatchTile) -> Array:
    var vertices := _get_shape_vertices_for_shape_type_at_top_left(
            shape_type,
            tile)
    
    # Flip vertically if needed.
    if !CornerDirection.get_is_top(corner_direction):
        for vertex_index in vertices.size():
            vertices[vertex_index].y = \
                    tile.tile_set._config.quadrant_size - \
                    vertices[vertex_index].y
    
    # Flip horizontally if needed.
    if !CornerDirection.get_is_left(corner_direction):
        for vertex_index in vertices.size():
            vertices[vertex_index].x = \
                    tile.tile_set._config.quadrant_size - \
                    vertices[vertex_index].x
    
    return vertices


func _get_shape_vertices_for_shape_type_at_top_left(
        shape_type: int,
        tile: CornerMatchTile) -> Array:
    var quadrant_size: int = tile.tile_set._config.quadrant_size
    var collision_margin: float = tile._config.subtile_collision_margin
    if collision_margin == 0.0:
        return _get_shape_vertices_for_shape_type_at_top_left_with_no_collision_margin(
                shape_type, tile)
    
    match shape_type:
        QuadrantShapeType.EMPTY:
            return []
        
        QuadrantShapeType.FULL_SQUARE:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_90_90:
            return [
                Vector2(0, collision_margin),
                Vector2(collision_margin, collision_margin),
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_45:
            return [
                Vector2(0, collision_margin),
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_TOP_90:
            return [
                Vector2(0, collision_margin),
                Vector2(quadrant_size, collision_margin),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_SIDE_90:
            return [
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(collision_margin, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_TOP_AND_SIDE_90:
            return [
                Vector2(collision_margin, collision_margin),
                Vector2(quadrant_size, collision_margin),
                Vector2(quadrant_size, quadrant_size),
                Vector2(collision_margin, quadrant_size),
            ]
        QuadrantShapeType.FLOOR_45_N:
            return [
                Vector2(0, collision_margin),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CEILING_45_N:
            return [
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size - collision_margin),
            ]
        QuadrantShapeType.EXT_90H_45_CONVEX_ACUTE:
            return [
                Vector2(collision_margin * 2, collision_margin),
                Vector2(quadrant_size, collision_margin),
                Vector2(quadrant_size, quadrant_size - collision_margin),
            ]
        QuadrantShapeType.EXT_90V_45_CONVEX_ACUTE:
            return [
                Vector2(collision_margin, collision_margin * 2),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(collision_margin, quadrant_size),
            ]
        
        QuadrantShapeType.FULL_SQUARE_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size - collision_margin),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_90_90_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, collision_margin),
                Vector2(collision_margin, collision_margin),
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size - collision_margin),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, collision_margin),
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size - collision_margin),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_TOP_90_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, collision_margin),
                Vector2(quadrant_size, collision_margin),
                Vector2(quadrant_size, quadrant_size - collision_margin),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_SIDE_90_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(collision_margin, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size - collision_margin),
                Vector2(quadrant_size - collision_margin, quadrant_size),
                Vector2(collision_margin, quadrant_size),
            ]
        
        _:
            Sc.logger.error(
                    "CornerMatchTilesetShapeCalculator" +
                    "._get_shape_vertices_for_shape_type_at_top_left")
            return []


func _get_shape_vertices_for_shape_type_at_top_left_with_no_collision_margin(
        shape_type: int,
        tile: CornerMatchTile) -> Array:
    var quadrant_size: int = tile.tile_set._config.quadrant_size
    
    match shape_type:
        QuadrantShapeType.EMPTY:
            return []
        
        QuadrantShapeType.FULL_SQUARE:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_90_90:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_45:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_TOP_90:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_SIDE_90:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_TOP_AND_SIDE_90:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.FLOOR_45_N:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CEILING_45_N:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
            ]
        QuadrantShapeType.EXT_90H_45_CONVEX_ACUTE:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
            ]
        QuadrantShapeType.EXT_90V_45_CONVEX_ACUTE:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        
        QuadrantShapeType.FULL_SQUARE_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_90_90_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.CLIPPED_CORNER_45_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_TOP_90_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        QuadrantShapeType.MARGIN_SIDE_90_CLIPPED_CORNER_45_OPP:
            return [
                Vector2(0, 0),
                Vector2(quadrant_size, 0),
                Vector2(quadrant_size, quadrant_size),
                Vector2(0, quadrant_size),
            ]
        
        _:
            Sc.logger.error(
                    "CornerMatchTilesetShapeCalculator" +
                    "._get_shape_vertices_for_shape_type_at_top_left")
            return []
