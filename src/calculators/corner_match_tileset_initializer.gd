tool
class_name CornerMatchTilesetInitializer
extends Node


func initialize_tileset(
        tile_set: CornerMatchTileset,
        forces_recalculate := false) -> void:
    for tile_config in tile_set._config.corner_match_tiles:
        _initialize_tile(tile_config.tile, forces_recalculate)
    tile_set.is_initialized = true


func _initialize_tile(
        tile: CornerMatchTile,
        forces_recalculate := false) -> void:
    tile.are_45_degree_subtiles_used = \
            tile._config.are_45_degree_subtiles_used
    tile.are_27_degree_subtiles_used = \
            tile._config.are_27_degree_subtiles_used
    
    tile._config.tileset_quadrants_texture = \
            load(tile._config.tileset_quadrants_path)
    
    tile.corner_type_annotation_key = load_annotation_key(
            tile, forces_recalculate)
    var subtile_corner_types := load_corner_types(
            tile, forces_recalculate)
    tile.subtile_corner_types = subtile_corner_types
    tile.empty_quadrants = _get_empty_quadrants(subtile_corner_types)
    tile.error_quadrants = _get_error_quadrants(subtile_corner_types)
    
    var shapes: Dictionary = St.shape_calculator \
            .create_tileset_shapes(subtile_corner_types, tile)
    # Dictionary<
    #   CornerDirection,
    #   Dictionary<
    #     SubtileCorner,
    #     Dictionary<
    #       SubtileCorner,
    #       Dictionary<
    #         SubtileCorner,
    #         Shape2D>>>>
    var collision_shapes: Dictionary = shapes.collision_shapes
    # Dictionary<
    #   CornerDirection,
    #   Dictionary<
    #     SubtileCorner,
    #     Dictionary<
    #       SubtileCorner,
    #       Dictionary<
    #         SubtileCorner,
    #         OccluderPolygon2D>>>>
    var occlusion_shapes: Dictionary = shapes.occlusion_shapes
    
    _initialize_inner_tile(
            tile,
            subtile_corner_types,
            collision_shapes,
            occlusion_shapes)
    
    tile._config.outer_tile_ids = []
    _initialize_outer_tile(
            tile,
            CellAngleType.A90)
    if tile._config.are_45_degree_subtiles_used:
        _initialize_outer_tile(
                tile,
                CellAngleType.A45)
    if tile._config.are_27_degree_subtiles_used:
        _initialize_outer_tile(
                tile,
                CellAngleType.A27)
    
    tile.is_initialized = true


func load_annotation_key(
        tile: CornerMatchTile,
        forces_recalculate: bool) -> Dictionary:
    var key := {}
    if !forces_recalculate:
        key = St.annotations_recorder.load_corner_type_annotation_key(
                St.corner_type_annotation_key_path)
    if key.empty():
        # FIXME: LEFT OFF HERE: -----------------
        # - We should specify a single global quadrant_size for the key, since
        #   tilesets should be able to use different sizes while sharing the
        #   same key.
        key = St.annotations_parser.parse_corner_type_annotation_key(
                St.corner_type_annotation_key_path,
                tile.tile_set._config.quadrant_size)
        St.annotations_recorder.save_corner_type_annotation_key(
                St.corner_type_annotation_key_path,
                key)
    return key


func load_corner_types(
        tile: CornerMatchTile,
        forces_recalculate: bool) -> Dictionary:
    var subtile_corner_types := {}
    if !forces_recalculate:
        subtile_corner_types = \
                St.annotations_recorder.load_tile_corner_type_annotations(
                    tile._config.tile_corner_type_annotations_path)
    if subtile_corner_types.empty():
        subtile_corner_types = \
                St.annotations_parser.parse_tile_corner_type_annotations(
                    tile._config.tile_corner_type_annotations_path,
                    tile.tile_set._config.quadrant_size,
                    tile)
        St.annotations_recorder.save_tile_corner_type_annotations(
                tile._config.tile_corner_type_annotations_path,
                subtile_corner_types)
    return subtile_corner_types


func _initialize_inner_tile(
        tile: CornerMatchTile,
        subtile_corner_types: Dictionary,
        collision_shapes: Dictionary,
        occlusion_shapes: Dictionary) -> void:
    var tile_name: String = "*" + tile._config.inner_autotile_name
    
    var tile_id := tile.tile_set.find_tile_by_name(tile_name)
    if tile_id >= 0:
        # Clear any pre-existing state for this tile.
        tile.tile_set.remove_tile(tile_id)
    else:
        tile_id = tile.tile_set.get_last_unused_tile_id()
    tile.tile_set.create_tile(tile_id)
    tile._config.inner_tile_id = tile_id
    tile.inner_tile_id = tile_id
    tile.inner_tile_name = tile_name
    tile.tile_set.ids_to_corner_match_tiles[tile_id] = tile
    
    var quadrants_texture_size: Vector2 = \
            tile._config.tileset_quadrants_texture.get_size()
    var tile_region := Rect2(Vector2.ZERO, quadrants_texture_size)
    
    var subtile_size: Vector2 = \
            Vector2.ONE * tile.tile_set._config.quadrant_size
    
    tile.tile_set.tile_set_name(tile_id, tile_name)
    tile.tile_set.tile_set_texture(tile_id, \
            tile._config.tileset_quadrants_texture)
    tile.tile_set.tile_set_region(tile_id, tile_region)
    tile.tile_set.tile_set_tile_mode(tile_id, TileSet.AUTO_TILE)
    tile.tile_set.autotile_set_size(tile_id, subtile_size)
    tile.tile_set.autotile_set_bitmask_mode(
            tile_id, TileSet.BITMASK_3X3_MINIMAL)
    
    _set_inner_tile_shapes_for_quadrants(
            tile,
            tile_id,
            subtile_corner_types,
            collision_shapes,
            occlusion_shapes)


func _initialize_outer_tile(
        tile: CornerMatchTile,
        angle_type: int) -> void:
    var tile_name_prefix: String
    var tile_name_suffix: String
    match angle_type:
        CellAngleType.A90:
            tile_name_prefix = "***"
            tile_name_suffix = "90"
        CellAngleType.A45:
            tile_name_prefix = "**"
            tile_name_suffix = "45"
        CellAngleType.A27:
            tile_name_prefix = "*"
            tile_name_suffix = "27"
        _:
            Sc.logger.error("CornerMatchTilesetInitializer._initialize_tile")
    
    var tile_name: String = \
            tile_name_prefix + \
            tile._config.outer_autotile_name + \
            tile_name_suffix
    
    var tile_id := tile.tile_set.find_tile_by_name(tile_name)
    if tile_id >= 0:
        # Clear any pre-existing state for this tile.
        tile.tile_set.remove_tile(tile_id)
    else:
        tile_id = tile.tile_set.get_last_unused_tile_id()
    tile.tile_set.create_tile(tile_id)
    tile._config.outer_tile_ids.push_back(tile_id)
    tile.tile_set.ids_to_corner_match_tiles[tile_id] = tile
    
    tile._tile_id_to_angle_type[tile_id] = angle_type
    tile._angle_type_to_tile_id[angle_type] = tile_id
    
    var empty_texture: Texture = load(Sc.images.TRANSPARENT_PIXEL_PATH)
    var empty_texture_size: Vector2 = empty_texture.get_size()
    var tile_region := Rect2(Vector2.ZERO, empty_texture_size)
    
    # FIXME: LEFT OFF HERE: -------------------------
    # - Do I need to scale the subtile/texture?
    # - Maybe I actually need to use the underlying quadrants texture, so that
    #   I can show the correct tile icon.
    
    var subtile_size: Vector2 = \
            Vector2.ONE * tile.tile_set._config.quadrant_size * 2
    
    tile.tile_set.tile_set_name(tile_id, tile_name)
    tile.tile_set.tile_set_texture(tile_id, empty_texture)
    tile.tile_set.tile_set_region(tile_id, tile_region)
    tile.tile_set.tile_set_tile_mode(tile_id, TileSet.AUTO_TILE)
    tile.tile_set.autotile_set_size(tile_id, subtile_size)
    tile.tile_set.autotile_set_bitmask_mode(
            tile_id, TileSet.BITMASK_3X3_MINIMAL)
    
    _set_outer_tile_icon_coordinates(tile, tile_id)


func _set_outer_tile_icon_coordinates(
        tile: CornerMatchTile,
        tile_id: int) -> void:
    # FIXME: LEFT OFF HERE: ----------------------------
    var icon_coordinate := Vector2.ZERO
    tile.tile_set.autotile_set_icon_coordinate(tile_id, icon_coordinate)


func _set_inner_tile_shapes_for_quadrants(
        tile: CornerMatchTile,
        tile_id: int,
        subtile_corner_types: Dictionary,
        collision_shapes: Dictionary,
        occlusion_shapes: Dictionary) -> void:
    for corner_direction in subtile_corner_types:
        var self_corner_type_map: Dictionary = \
                subtile_corner_types[corner_direction]
        for self_corner_type in self_corner_type_map:
            var h_internal_corner_type_map_or_position = \
                    self_corner_type_map[self_corner_type]
            if h_internal_corner_type_map_or_position is Vector2:
                _set_inner_tile_shapes_for_quadrants_recursively(
                        tile,
                        tile_id,
                        h_internal_corner_type_map_or_position,
                        self_corner_type,
                        SubtileCorner.UNKNOWN,
                        SubtileCorner.UNKNOWN,
                        corner_direction,
                        collision_shapes,
                        occlusion_shapes)
                continue
            for h_internal_corner_type in \
                    h_internal_corner_type_map_or_position:
                var v_internal_corner_type_map_or_position = \
                        h_internal_corner_type_map_or_position[ \
                            h_internal_corner_type]
                if v_internal_corner_type_map_or_position is Vector2:
                    _set_inner_tile_shapes_for_quadrants_recursively(
                            tile,
                            tile_id,
                            v_internal_corner_type_map_or_position,
                            self_corner_type,
                            h_internal_corner_type,
                            SubtileCorner.UNKNOWN,
                            corner_direction,
                            collision_shapes,
                            occlusion_shapes)
                    continue
                for v_internal_corner_type in \
                        v_internal_corner_type_map_or_position:
                    _set_inner_tile_shapes_for_quadrants_recursively(
                            tile,
                            tile_id,
                            v_internal_corner_type_map_or_position \
                                [v_internal_corner_type],
                            self_corner_type,
                            h_internal_corner_type,
                            v_internal_corner_type,
                            corner_direction,
                            collision_shapes,
                            occlusion_shapes)


func _set_inner_tile_shapes_for_quadrants_recursively(
        tile: CornerMatchTile,
        tile_id: int,
        position_or_map,
        self_corner_type: int,
        h_internal_corner_type: int,
        v_internal_corner_type: int,
        corner_direction: int,
        collision_shapes: Dictionary,
        occlusion_shapes: Dictionary) -> void:
    if position_or_map is Vector2:
        _set_shapes_for_quadrant(
                tile,
                tile_id,
                position_or_map,
                self_corner_type,
                h_internal_corner_type,
                v_internal_corner_type,
                corner_direction,
                collision_shapes,
                occlusion_shapes)
    else:
        for key in position_or_map:
            _set_inner_tile_shapes_for_quadrants_recursively(
                    tile,
                    tile_id,
                    position_or_map[key],
                    self_corner_type,
                    h_internal_corner_type,
                    v_internal_corner_type,
                    corner_direction,
                    collision_shapes,
                    occlusion_shapes)


func _set_shapes_for_quadrant(
        tile: CornerMatchTile,
        tile_id: int,
        quadrant_position: Vector2,
        self_corner_type: int,
        h_internal_corner_type: int,
        v_internal_corner_type: int,
        corner_direction: int,
        collision_shapes: Dictionary,
        occlusion_shapes: Dictionary) -> void:
    var collision_shape: Shape2D = collision_shapes \
            [corner_direction] \
            [self_corner_type] \
            [h_internal_corner_type] \
            [v_internal_corner_type]
    var occlusion_shape: OccluderPolygon2D = occlusion_shapes \
            [corner_direction] \
            [self_corner_type] \
            [h_internal_corner_type] \
            [v_internal_corner_type]
    
    if is_instance_valid(collision_shape):
        tile.tile_set.tile_add_shape(
                tile_id,
                collision_shape,
                Transform2D.IDENTITY,
                false,
                quadrant_position)
        tile.tile_set.autotile_set_light_occluder(
                tile_id,
                occlusion_shape,
                quadrant_position)
    
    var bitmask := \
            TileSet.BIND_TOPLEFT | \
            TileSet.BIND_TOP | \
            TileSet.BIND_TOPRIGHT | \
            TileSet.BIND_LEFT | \
            TileSet.BIND_CENTER | \
            TileSet.BIND_RIGHT | \
            TileSet.BIND_BOTTOMLEFT | \
            TileSet.BIND_BOTTOM | \
            TileSet.BIND_BOTTOMRIGHT if \
            is_instance_valid(collision_shape) else \
            TileSet.BIND_CENTER
    tile.tile_set.autotile_set_bitmask(
            tile_id,
            quadrant_position,
            bitmask)


func _get_error_quadrants(subtile_corner_types: Dictionary) -> Array:
    var tl_quadrant_position: Vector2 = subtile_corner_types \
            [CornerDirection.TOP_LEFT] \
            [SubtileCorner.ERROR]
    var tr_quadrant_position: Vector2 = subtile_corner_types \
            [CornerDirection.TOP_RIGHT] \
            [SubtileCorner.ERROR]
    var bl_quadrant_position: Vector2 = subtile_corner_types \
            [CornerDirection.BOTTOM_LEFT] \
            [SubtileCorner.ERROR]
    var br_quadrant_position: Vector2 = subtile_corner_types \
            [CornerDirection.BOTTOM_RIGHT] \
            [SubtileCorner.ERROR]
    return [
        tl_quadrant_position,
        tr_quadrant_position,
        bl_quadrant_position,
        br_quadrant_position,
    ]


func _get_empty_quadrants(subtile_corner_types: Dictionary) -> Array:
    var tl_quadrant_position_or_map = subtile_corner_types \
            [CornerDirection.TOP_LEFT] \
            [SubtileCorner.EMPTY]
    while tl_quadrant_position_or_map is Dictionary:
        tl_quadrant_position_or_map = \
                tl_quadrant_position_or_map[SubtileCorner.UNKNOWN]
    var tr_quadrant_position_or_map = subtile_corner_types \
            [CornerDirection.TOP_RIGHT] \
            [SubtileCorner.EMPTY]
    while tr_quadrant_position_or_map is Dictionary:
        tr_quadrant_position_or_map = \
                tr_quadrant_position_or_map[SubtileCorner.UNKNOWN]
    var bl_quadrant_position_or_map = subtile_corner_types \
            [CornerDirection.BOTTOM_LEFT] \
            [SubtileCorner.EMPTY]
    while bl_quadrant_position_or_map is Dictionary:
        bl_quadrant_position_or_map = \
                bl_quadrant_position_or_map[SubtileCorner.UNKNOWN]
    var br_quadrant_position_or_map = subtile_corner_types \
            [CornerDirection.BOTTOM_RIGHT] \
            [SubtileCorner.EMPTY]
    while br_quadrant_position_or_map is Dictionary:
        br_quadrant_position_or_map = \
                br_quadrant_position_or_map[SubtileCorner.UNKNOWN]
    return [
        tl_quadrant_position_or_map,
        tr_quadrant_position_or_map,
        bl_quadrant_position_or_map,
        br_quadrant_position_or_map,
    ]
