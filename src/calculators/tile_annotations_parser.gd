tool
class_name TileAnnotationsParser
extends Node


const ANNOTATION_SIZE := 4

# This is an int with the first 10 bits set.
const _CORNER_TYPE_BIT_MASK := (1 << 10) - 1

var _EMPTY_ANNOTATION := {
    bits = 0,
    color = Color.transparent.to_rgba32(),
}


# -   Returns a mapping from pixel-color to pixel-bit-flag to corner-type.
# Dictionary<int<Color>, Dictionary<int<Bits>, SubtileCorner>>
func parse_corner_type_annotation_key(
        corner_type_annotation_key_path: String,
        quadrant_size: int) -> Dictionary:
    assert(quadrant_size >= ANNOTATION_SIZE * 2)
    assert(quadrant_size >= ANNOTATION_SIZE * 2)
    
    var texture: Texture = load(corner_type_annotation_key_path)
    var image: Image = texture.get_data()
    
    var size := image.get_size()
    assert(int(size.x) % quadrant_size == 0)
    assert(int(size.y) % quadrant_size == 0)
    
    var quadrant_row_count := int(size.y) / quadrant_size
    var quadrant_column_count := int(size.x) / quadrant_size
    
    var quadrant_count := quadrant_row_count * quadrant_column_count
    var corner_type_count := SubtileCorner.get_script_constant_map().size()
    assert(quadrant_count >= corner_type_count or \
            quadrant_count <= corner_type_count + quadrant_row_count - 1,
            "The corner-type annotation key must have an entry for each " +
            "corner-type enum and no extras.")
    
    var corner_type_annotation_key := {}
    
    image.lock()
    
    for quadrant_row_index in quadrant_row_count:
        for quadrant_column_index in quadrant_column_count:
            var quadrant_position := \
                    Vector2(quadrant_column_index, quadrant_row_index) * \
                    quadrant_size
            _check_for_empty_non_annotation_pixels(
                    quadrant_position,
                    CornerDirection.TOP_LEFT,
                    quadrant_size,
                    image,
                    corner_type_annotation_key_path)
            # This int corresponds to the SubtileCorner enum value.
            var corner_type := int(
                    quadrant_row_index * quadrant_column_count + \
                    quadrant_column_index)
            if corner_type >= \
                    St.SUBTILE_CORNER_TYPE_VALUE_TO_KEY.size():
                # We've reached the end of the annotation key, and any remaining
                # cells should be empty.
                break
            var annotation := _get_annotation(
                    quadrant_position,
                    CornerDirection.TOP_LEFT,
                    ConnectionDirection.SELF,
                    quadrant_size,
                    image)
            if quadrant_position == Vector2.ZERO:
                continue
            if !corner_type_annotation_key.has(annotation.color):
                corner_type_annotation_key[annotation.color] = {}
            _validate_annotation_key_annotation(
                    annotation,
                    quadrant_position,
                    CornerDirection.TOP_LEFT,
                    ConnectionDirection.SELF,
                    quadrant_size,
                    corner_type_annotation_key,
                    corner_type_annotation_key_path)
            corner_type_annotation_key[annotation.color][annotation.bits] = \
                    corner_type
    
    image.unlock()
    
    return corner_type_annotation_key


# Dictionary<
#   CornerDirection,
#   Dictionary<
#     SubtileCorner, # Self-corner
#     (Vector2|Dictionary<
#       SubtileCorner, # H-internal-corner
#       (Vector2|Dictionary<
#         SubtileCorner, # V-internal-corner
#         (Vector2|Dictionary<
#           SubtileCorner, # H-external-corner
#           (Vector2|Dictionary<
#             SubtileCorner, # V-external-corner
#             (Vector2|Dictionary<
#               SubtileCorner, # Diagonal-internal-corner
#               (Vector2|Dictionary<
#                 SubtileCorner, # HD-external-corner
#                 (Vector2|Dictionary<
#                   SubtileCorner, # VD-external-corner
#                   (Vector2|Dictionary<
#                     SubtileCorner, # H2-external-corner
#                     (Vector2|Dictionary<
#                       SubtileCorner, # V2-external-corner
#                       (Vector2|Dictionary<
#                         SubtileCorner, # HD2-external-corner
#                         (Vector2|Dictionary<
#                           SubtileCorner, # VD2-external-corner
#                           Vector2        # Quadrant coordinates
#                         >)>)>)>)>)>)>)>)>)>>
func parse_tile_corner_type_annotations(
        tile_corner_type_annotations_path: String,
        quadrant_size: int,
        tile: CornerMatchTile) -> Dictionary:
    var corner_type_annotation_key := tile.corner_type_annotation_key
    var subtile_size := quadrant_size * 2
    
    var texture: Texture = load(tile_corner_type_annotations_path)
    var image: Image = texture.get_data()
    
    var size := image.get_size()
    assert(int(size.x) % subtile_size == 0)
    assert(int(size.y) % subtile_size == 0)
    
    var subtile_row_count := int(size.y) / subtile_size
    var subtile_column_count := int(size.x) / subtile_size
    
    var subtile_corner_types := {
        CornerDirection.TOP_LEFT: {},
        CornerDirection.TOP_RIGHT: {},
        CornerDirection.BOTTOM_LEFT: {},
        CornerDirection.BOTTOM_RIGHT: {},
    }
    
    image.lock()
    
    for subtile_row_index in subtile_row_count:
        for subtile_column_index in subtile_column_count:
            var subtile_position := \
                    Vector2(subtile_column_index, subtile_row_index) * \
                    subtile_size
            _parse_corner_type_annotation(
                    subtile_corner_types,
                    corner_type_annotation_key,
                    subtile_position,
                    quadrant_size,
                    image,
                    tile_corner_type_annotations_path)
    
    _validate_quadrants(subtile_corner_types, tile)
    
    image.unlock()
    
    return subtile_corner_types


func parse_quadrant(
        subtile_position: Vector2,
        corner_direction: int,
        quadrant_size: int,
        tileset_image_path: String,
        corner_type_annotation_key: Dictionary) -> Array:
    var texture: Texture = load(tileset_image_path)
    var image: Image = texture.get_data()
    
    image.lock()
    
    var connection_types_map := {}
    for connection_direction in ConnectionDirection.CONNECTIONS:
        for current_corner_direction in CornerDirection.CORNERS:
            _parse_connection(
                    connection_types_map,
                    current_corner_direction,
                    connection_direction,
                    subtile_position,
                    quadrant_size,
                    corner_type_annotation_key,
                    image,
                    tileset_image_path)
    
    image.unlock()
    
    var results := []
    for connection_direction in \
            ConnectionDirection.CONNECTIONS_IN_QUADRANT_MATCH_PRIORITY_ORDER:
        results.push_back(
                connection_types_map[corner_direction][connection_direction])
    
    return results


func _parse_corner_type_annotation(
        subtile_corner_types: Dictionary,
        corner_type_annotation_key: Dictionary,
        subtile_position: Vector2,
        quadrant_size: int,
        image: Image,
        path: String) -> void:
    _check_for_empty_non_annotation_pixels(
            subtile_position + Vector2(0, 0),
            CornerDirection.TOP_LEFT,
            quadrant_size,
            image,
            path)
    _check_for_empty_non_annotation_pixels(
            subtile_position + Vector2(quadrant_size, 0),
            CornerDirection.TOP_RIGHT,
            quadrant_size,
            image,
            path)
    _check_for_empty_non_annotation_pixels(
            subtile_position + Vector2(0, quadrant_size),
            CornerDirection.BOTTOM_LEFT,
            quadrant_size,
            image,
            path)
    _check_for_empty_non_annotation_pixels(
            subtile_position + Vector2(quadrant_size, quadrant_size),
            CornerDirection.BOTTOM_RIGHT,
            quadrant_size,
            image,
            path)
    
    # Dictionary<CornerDirection, Dictionary<ConnectionType, SubtileCorner>>
    var connection_types_map := {}
    
    for connection_direction in ConnectionDirection.CONNECTIONS:
        for corner_direction in CornerDirection.CORNERS:
            _parse_connection(
                    connection_types_map,
                    corner_direction,
                    connection_direction,
                    subtile_position,
                    quadrant_size,
                    corner_type_annotation_key,
                    image,
                    path)
    
    for connection_direction in ConnectionDirection.CONNECTIONS:
        for corner_direction in CornerDirection.CORNERS:
            assert(connection_types_map \
                        [corner_direction][ConnectionDirection.SELF] != \
                        SubtileCorner.UNKNOWN or \
                    connection_types_map \
                        [corner_direction][connection_direction] == \
                        SubtileCorner.UNKNOWN,
                    ("Subtile self-corner-type annotation is empty, " +
                    "but not all neighbor-connection annotations are empty: " +
                    "%s") % _get_log_string(
                        _get_quadrant_position(
                                subtile_position,
                                quadrant_size,
                                corner_direction),
                        corner_direction,
                        connection_direction,
                        quadrant_size,
                        path))
    
    for corner_direction in CornerDirection.CORNERS:
        if connection_types_map[corner_direction][ConnectionDirection.SELF] == \
                SubtileCorner.UNKNOWN:
            continue
        _record_quadrant(
                subtile_corner_types,
                corner_direction,
                subtile_position,
                quadrant_size,
                connection_types_map)


static func _parse_connection(
        connection_types_map: Dictionary,
        corner_direction: int,
        connection_direction: int,
        subtile_position: Vector2,
        quadrant_size: int,
        corner_type_annotation_key: Dictionary,
        image: Image,
        path: String) -> void:
    var quadrant_position := _get_quadrant_position(
            subtile_position,
            quadrant_size,
            corner_direction)
    var has_implicit_connection := _get_implicit_connection_indicator(
            quadrant_position,
            corner_direction,
            connection_direction,
            quadrant_size,
            image,
            path)
    var corner_type := _get_explicit_connection_type(
            quadrant_position,
            corner_direction,
            connection_direction,
            quadrant_size,
            corner_type_annotation_key,
            image,
            path)
    assert(!has_implicit_connection or \
                corner_type == SubtileCorner.UNKNOWN,
            ("Both an explicit connection annotation and implicit " +
            "connection indicator pixel is defined for the same quadrant: %s") % 
                _get_log_string(
                    quadrant_position,
                    corner_direction,
                    connection_direction,
                    quadrant_size,
                    path))
    if has_implicit_connection:
        corner_type = _get_implicit_connection_type(
                quadrant_position,
                corner_direction,
                connection_direction,
                quadrant_size,
                corner_type_annotation_key,
                connection_types_map,
                image,
                path)
        assert(corner_type != SubtileCorner.UNKNOWN,
            ("Neighbor annotation-type is UNKNOWN for an implicit " +
            "connection: %s") % 
                _get_log_string(
                    quadrant_position,
                    corner_direction,
                    connection_direction,
                    quadrant_size,
                    path))
    # Record the result.
    if !connection_types_map.has(corner_direction):
        connection_types_map[corner_direction] = {}
    connection_types_map[corner_direction][connection_direction] = corner_type


static func _get_implicit_connection_indicator(
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        image: Image,
        path: String) -> bool:
    var x_offset: int
    var y_offset: int
    
    match connection_direction:
        ConnectionDirection.SELF:
            return false
        
        ConnectionDirection.H_INTERNAL:
            x_offset = quadrant_size - 1
            y_offset = quadrant_size - 2
        ConnectionDirection.V_INTERNAL:
            x_offset = quadrant_size - 2
            y_offset = quadrant_size - 1
        ConnectionDirection.D_INTERNAL:
            x_offset = quadrant_size - 1
            y_offset = quadrant_size - 1
        
        ConnectionDirection.H_EXTERNAL:
            x_offset = 0
            y_offset = quadrant_size - 2
        ConnectionDirection.H2_EXTERNAL:
            x_offset = 1
            y_offset = quadrant_size - 2
        ConnectionDirection.HD_EXTERNAL:
            x_offset = 0
            y_offset = quadrant_size - 1
        ConnectionDirection.HD2_EXTERNAL:
            x_offset = 1
            y_offset = quadrant_size - 1
        
        ConnectionDirection.V_EXTERNAL:
            x_offset = quadrant_size - 2
            y_offset = 0
        ConnectionDirection.V2_EXTERNAL:
            x_offset = quadrant_size - 2
            y_offset = 1
        ConnectionDirection.VD_EXTERNAL:
            x_offset = quadrant_size - 1
            y_offset = 0
        ConnectionDirection.VD2_EXTERNAL:
            x_offset = quadrant_size - 1
            y_offset = 1
        
        _:
            Sc.logger.error(
                    "TileAnnotationsParser._get_implicit_connection_indicator")
    
    if !CornerDirection.get_is_top(corner_direction):
        y_offset = quadrant_size - 1 - y_offset
    if !CornerDirection.get_is_left(corner_direction):
        x_offset = quadrant_size - 1 - x_offset
    
    var x := int(quadrant_position.x + x_offset)
    var y := int(quadrant_position.y + y_offset)
    var color := image.get_pixel(x, y)
    
    return color == St.implicit_quadrant_connection_color


static func _get_annotation(
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        image: Image) -> Dictionary:
    var region_start: Vector2
    match connection_direction:
        ConnectionDirection.SELF:
            region_start = Vector2(
                    0,
                    0)
        ConnectionDirection.H_INTERNAL:
            region_start = Vector2(
                    quadrant_size - ANNOTATION_SIZE,
                    quadrant_size - ANNOTATION_SIZE * 2)
        ConnectionDirection.V_INTERNAL:
            region_start = Vector2(
                    quadrant_size - ANNOTATION_SIZE * 2,
                    quadrant_size - ANNOTATION_SIZE)
        ConnectionDirection.D_INTERNAL:
            region_start = Vector2(
                    quadrant_size - ANNOTATION_SIZE,
                    quadrant_size - ANNOTATION_SIZE)
        ConnectionDirection.H_EXTERNAL:
            region_start = Vector2(
                    ANNOTATION_SIZE,
                    0)
        ConnectionDirection.H2_EXTERNAL:
            region_start = Vector2(
                    ANNOTATION_SIZE * 2,
                    0)
        ConnectionDirection.HD_EXTERNAL:
            region_start = Vector2(
                    0,
                    quadrant_size - ANNOTATION_SIZE)
        ConnectionDirection.HD2_EXTERNAL:
            region_start = Vector2(
                    ANNOTATION_SIZE,
                    quadrant_size - ANNOTATION_SIZE)
        ConnectionDirection.V_EXTERNAL:
            region_start = Vector2(
                    0,
                    ANNOTATION_SIZE)
        ConnectionDirection.V2_EXTERNAL:
            region_start = Vector2(
                    0,
                    ANNOTATION_SIZE * 2)
        ConnectionDirection.VD_EXTERNAL:
            region_start = Vector2(
                    quadrant_size - ANNOTATION_SIZE,
                    0)
        ConnectionDirection.VD2_EXTERNAL:
            region_start = Vector2(
                    quadrant_size - ANNOTATION_SIZE,
                    ANNOTATION_SIZE)
        _:
            Sc.logger.error("TileAnnotationsParser._get_quadrant_annotation")
    
    if !CornerDirection.get_is_left(corner_direction):
        region_start.x = quadrant_size - ANNOTATION_SIZE - region_start.x
    if !CornerDirection.get_is_top(corner_direction):
        region_start.y = quadrant_size - ANNOTATION_SIZE - region_start.y
    
    return _get_annotation_in_region(
            quadrant_position + region_start,
            image,
            ConnectionDirection.get_is_top(
                corner_direction, connection_direction),
            ConnectionDirection.get_is_left(
                corner_direction, connection_direction))


static func _get_annotation_in_region(
        region_start: Vector2,
        image: Image,
        is_top: bool,
        is_left: bool) -> Dictionary:
    var annotation_bits := 0
    var annotation_color := Color.transparent
    
    for annotation_row_index in ANNOTATION_SIZE:
        for annotation_column_index in ANNOTATION_SIZE:
            var x := int(region_start.x + (
                    annotation_column_index if \
                    is_left else \
                    ANNOTATION_SIZE - 1 - annotation_column_index))
            var y := int(region_start.y + (
                    annotation_row_index if \
                    is_top else \
                    ANNOTATION_SIZE - 1 - annotation_row_index))
            
            var color := image.get_pixel(x, y)
            if color.a == 0:
                # Ignore empty pixels.
                continue
            if color.a != 0 and \
                    color != annotation_color and \
                    annotation_color.a != 0:
                # This is an error indication.
                return {color = -1}
            
            var bit_index := int(
                    annotation_row_index * ANNOTATION_SIZE + \
                    annotation_column_index)
            
            annotation_color = color
            annotation_bits |= 1 << bit_index
    
    return {
        bits = annotation_bits,
        color = annotation_color.to_rgba32(),
    }


static func _get_explicit_connection_type(
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        corner_type_annotation_key: Dictionary,
        image: Image,
        path: String) -> int:
    var annotation := _get_annotation(
            quadrant_position,
            corner_direction,
            connection_direction,
            quadrant_size,
            image)
    if connection_direction != ConnectionDirection.SELF and \
            annotation.color == \
            St.implicit_quadrant_connection_color.to_rgba32():
        # Skip any possible explicit-annotation interpretation for the
        # implicit-annotation color.
        return SubtileCorner.UNKNOWN
    _validate_tileset_annotation(
            annotation,
            quadrant_position,
            corner_direction,
            connection_direction,
            quadrant_size,
            corner_type_annotation_key,
            path)
    if annotation.bits == 0:
        # Empty quadrant.
        return SubtileCorner.UNKNOWN
    return _get_corner_type_from_annotation(
            annotation,
            corner_type_annotation_key)


static func _get_implicit_connection_type(
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        corner_type_annotation_key: Dictionary,
        connection_types_map: Dictionary,
        image: Image,
        path: String) -> int:
    var neighbor_quadrant_corner_direction := corner_direction
    if ConnectionDirection \
            .get_does_connection_direction_flip_top(connection_direction):
        neighbor_quadrant_corner_direction = \
                CornerDirection.get_vertical_flip(
                    neighbor_quadrant_corner_direction)
    if ConnectionDirection \
            .get_does_connection_direction_flip_left(connection_direction):
        neighbor_quadrant_corner_direction = \
                CornerDirection.get_horizontal_flip(
                    neighbor_quadrant_corner_direction)
    
    var neighbor_quadrant_offset: Vector2
    
    match connection_direction:
        ConnectionDirection.H_INTERNAL, \
        ConnectionDirection.V_INTERNAL, \
        ConnectionDirection.D_INTERNAL:
            # This neighbor type should already have been parsed.
            return connection_types_map \
                    [neighbor_quadrant_corner_direction] \
                    [ConnectionDirection.SELF]
        ConnectionDirection.HD_EXTERNAL:
            # This neighbor type should already have been parsed.
            neighbor_quadrant_corner_direction = \
                    CornerDirection.get_horizontal_flip(
                        neighbor_quadrant_corner_direction)
            return connection_types_map \
                    [neighbor_quadrant_corner_direction] \
                    [ConnectionDirection.H_EXTERNAL]
        ConnectionDirection.VD_EXTERNAL:
            # This neighbor type should already have been parsed.
            neighbor_quadrant_corner_direction = \
                    CornerDirection.get_vertical_flip(
                        neighbor_quadrant_corner_direction)
            return connection_types_map \
                    [neighbor_quadrant_corner_direction] \
                    [ConnectionDirection.V_EXTERNAL]
        
        ConnectionDirection.H_EXTERNAL:
            neighbor_quadrant_offset = Vector2(-quadrant_size, 0)
        ConnectionDirection.H2_EXTERNAL:
            neighbor_quadrant_offset = Vector2(-quadrant_size * 2, 0)
        ConnectionDirection.V_EXTERNAL:
            neighbor_quadrant_offset = Vector2(0, -quadrant_size)
        ConnectionDirection.V2_EXTERNAL:
            neighbor_quadrant_offset = Vector2(0, -quadrant_size * 2)
        
        _:
            Sc.logger.error("TileAnnotationsParser._get_implicit_connection_type")
    
    if !CornerDirection.get_is_top(corner_direction):
        neighbor_quadrant_offset.y *= -1
    if !CornerDirection.get_is_left(corner_direction):
        neighbor_quadrant_offset.x *= -1
    
    return _get_explicit_connection_type(
            quadrant_position + neighbor_quadrant_offset,
            neighbor_quadrant_corner_direction,
            ConnectionDirection.SELF,
            quadrant_size,
            corner_type_annotation_key,
            image,
            path)


static func _record_quadrant(
        subtile_corner_types: Dictionary,
        corner_direction: int,
        subtile_position: Vector2,
        quadrant_size: int,
        connection_types_map: Dictionary) -> void:
    var quadrant_position := _get_quadrant_position(
            subtile_position,
            quadrant_size,
            corner_direction)
    var quadrant_coordinates := quadrant_position / quadrant_size
    
    var corner_to_connections: Dictionary = \
            connection_types_map[corner_direction]
    
    var keys := ConnectionDirection \
            .CONNECTIONS_IN_QUADRANT_MATCH_PRIORITY_ORDER.duplicate()
    for i in keys.size():
        keys[i] = corner_to_connections[keys[i]]
    keys.push_back(quadrant_coordinates)
    
    var index_of_last_known_type := 0
    for i in keys.size() - 1:
        if keys[i] != SubtileCorner.UNKNOWN:
            index_of_last_known_type = i
    
    var map: Dictionary = subtile_corner_types[corner_direction]
    
    _record_quadrant_coordinates_recursively(
            map,
            keys,
            0,
            index_of_last_known_type)


static func _record_quadrant_coordinates_recursively(
        map: Dictionary,
        keys: Array,
        index: int,
        index_of_last_known_type: int) -> void:
    var current_key = keys[index]
    var next_key_or_value = keys[index + 1]
    
    assert(current_key is int or current_key is float)
    # JSON encoding may have converted this into a float.
    current_key = int(current_key)
    assert(index < keys.size() - 2 or \
            next_key_or_value is Vector2)
    
    if map.has(current_key):
        var preexisting_value = map[current_key]
        if preexisting_value is Vector2:
            if next_key_or_value is Vector2 or \
                    index >= index_of_last_known_type:
                # Base case:
                # -   Do nothing.
                # -   Keep the earlier coordinates when there are multiple
                #     coordinates with the same corner-types.
                pass
            else:
                # Recursive case:
                # -   Record a new map.
                # -   Record a mapping from UNKNOWN to the preexisting value.
                # -   Recurse.
                var next_map := {}
                map[current_key] = next_map
                next_map[SubtileCorner.UNKNOWN] = preexisting_value
                _record_quadrant_coordinates_recursively(
                        next_map,
                        keys,
                        index + 1,
                        index_of_last_known_type)
        else:
            var next_map: Dictionary = preexisting_value
            _record_quadrant_coordinates_recursively(
                    next_map,
                    keys,
                    index + 1,
                    index_of_last_known_type)
    else:
        if next_key_or_value is Vector2:
            # Base case: Record the quadrant coordinates.
            map[current_key] = next_key_or_value
        elif index >= index_of_last_known_type:
            # Base case:
            # -   Record the quadrant coordinates.
            # -   In this case, some of the connected corner-types are
            #     undefined.
            # -   Rather than create extra nested dictionaries with mappings
            #     from SubtileCorner.UNKNOWN, we just record a mapping from
            #     UNKNOWN directly to the quadrant coordinates on the last
            #     preexisting dictionary in the chain.
            map[current_key] = keys.back()
        else:
            # Recursive case: Record a new map and recurse.
            var next_map := {}
            map[current_key] = next_map
            _record_quadrant_coordinates_recursively(
                    next_map,
                    keys,
                    index + 1,
                    index_of_last_known_type)


static func _get_corner_type_from_annotation(
        annotation: Dictionary,
        corner_type_annotation_key: Dictionary) -> int:
    if annotation.bits == 0:
        return SubtileCorner.UNKNOWN
    return corner_type_annotation_key[annotation.color][annotation.bits]


static func _get_quadrant_position(
        subtile_position: Vector2,
        quadrant_size: int,
        corner_direction: int) -> Vector2:
    match corner_direction:
        CornerDirection.TOP_LEFT:
            return subtile_position
        CornerDirection.TOP_RIGHT:
            return subtile_position + Vector2(1,0) * quadrant_size
        CornerDirection.BOTTOM_LEFT:
            return subtile_position + Vector2(0,1) * quadrant_size
        CornerDirection.BOTTOM_RIGHT:
            return subtile_position + Vector2(1,1) * quadrant_size
        _:
            Sc.logger.error("TileAnnotationsParser._get_quadrant_position")
            return Vector2.INF


static func _check_for_empty_non_annotation_pixels(
        quadrant_position: Vector2,
        corner_direction: int,
        quadrant_size: int,
        image: Image,
        path: String) -> void:
    var center_region := Rect2(
            Vector2.ONE * ANNOTATION_SIZE,
            Vector2.ONE * (quadrant_size - ANNOTATION_SIZE * 2))
    for quadrant_y in range(center_region.position.y, center_region.end.y):
        for quadrant_x in range(center_region.position.x, center_region.end.x):
            var color := image.get_pixel(
                    quadrant_position.x + quadrant_x,
                    quadrant_position.y + quadrant_y)
            assert(color.a == 0,
                    ("Non-annotation-region pixels must be empty: " +
                    "pixel_position=(%s,%s), " +
                    "pixel_position=(%s,%s), " +
                    "color=%s, " +
                    "%s") % [
                        quadrant_x,
                        quadrant_y,
                        quadrant_position.x + quadrant_x,
                        quadrant_position.y + quadrant_y,
                        str(color),
                        _get_log_string(
                            quadrant_position,
                            corner_direction,
                            ConnectionDirection.SELF,
                            quadrant_size,
                            path),
                    ])


static func _validate_annotation_key_annotation(
        annotation: Dictionary,
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        corner_type_annotation_key: Dictionary,
        path: String) -> void:
    var color: int = annotation.color
    var bits: int = annotation.bits
    
    assert(color >= 0,
            ("Each corner-type annotation should use only a " +
            "single color: %s") % _get_log_string(
                quadrant_position,
                CornerDirection.TOP_LEFT,
                ConnectionDirection.SELF,
                quadrant_size,
                path))
    
    assert(color != \
            St.implicit_quadrant_connection_color.to_rgba32(),
            ("A corner-type annotation cannot use the color that's " +
            "configured as the implicit_quadrant_connection_color: " +
            "color=%s, implicit_connection_color=%s, %s") % [
                Color(color).to_html(),
                Color(St.implicit_quadrant_connection_color) \
                    .to_html(),
                _get_log_string(
                    quadrant_position,
                    CornerDirection.TOP_LEFT,
                    ConnectionDirection.SELF,
                    quadrant_size,
                    path),
            ])
    
    if quadrant_position == Vector2.ZERO:
        assert(bits == 0,
                "The first corner-type annotation in the " +
                "annotation-key corresponds to UNKNOWN and must be " +
                "empty.")
        return
    
    assert(bits != 0,
            "Corner-type annotations cannot be empty: %s" % \
            _get_log_string(
                quadrant_position,
                CornerDirection.TOP_LEFT,
                ConnectionDirection.SELF,
                quadrant_size,
                path))
    
    assert(!corner_type_annotation_key[color].has(bits),
            "Multiple corner-type annotations have the same shape " +
            "and color: %s" % _get_log_string(
                quadrant_position,
                CornerDirection.TOP_LEFT,
                ConnectionDirection.SELF,
                quadrant_size,
                path))


static func _validate_tileset_annotation(
        annotation: Dictionary,
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        corner_type_annotation_key: Dictionary,
        path: String) -> void:
    assert(annotation.color >= 0,
            ("Each corner-type annotation should use only a single color: %s") %
            _get_log_string(
                quadrant_position,
                corner_direction,
                connection_direction,
                quadrant_size,
                path))
    
    var bits: int = annotation.bits
    var color: int = annotation.color
    
    if annotation.bits == 0:
        # Empty quadrant.
        return
    
    assert(corner_type_annotation_key.has(color),
            ("Annotation color doesn't match the annotation key: " +
            "color=%s, %s") % [
                Color(color).to_html(),
                _get_log_string(
                    quadrant_position,
                    corner_direction,
                    connection_direction,
                    quadrant_size,
                    path),
            ])
    
    if !corner_type_annotation_key[color].has(bits):
        var shape_string := ""
        for column_index in ANNOTATION_SIZE:
            shape_string += "\n"
            for row_index in ANNOTATION_SIZE:
                var bit_index := \
                        int(row_index * ANNOTATION_SIZE + column_index)
                var pixel_flag := 1 << bit_index
                var is_pixel_present := (bits & pixel_flag) != 0
                shape_string += "*" if is_pixel_present else "."
        Sc.logger.error(
                ("Corner-type-annotation shape doesn't match the " +
                "annotation key: %s\n%s") % [
                    shape_string,
                    _get_log_string(
                        quadrant_position,
                        corner_direction,
                        connection_direction,
                        quadrant_size,
                        path),
                ])


static func _validate_quadrants(
        subtile_corner_types: Dictionary,
        tile: CornerMatchTile) -> void:
    # FIXME: LEFT OFF HERE: ----------------------
    # - Check that many corner-types are defined at least once for all four
    #   corner-directions.
    # - ERROR
    # - EMPTY
    # - FULLY_INTERNAL
    # - All 90s
    # - Some basic 45s, if configured to use 45s
    # - Some basic 27s, if configured to use 27s
    
    # FIXME: LEFT OFF HERE: --------------------------------------
    # - Anything else to validate?
    # - Check notes...
    
    # FIXME: LEFT OFF HERE: --------------------------------------
    # - Abandon the below config-based checks, and instead parse a separate
    #   min-required-corner-types image.
    
    # [self, h_internal, v_internal]
    var REQUIRED_90_QUADRANT_CORNER_TYPES := [
#        [SubtileCorner.ERROR, SubtileCorner.ERROR, SubtileCorner.ERROR],
#        [SubtileCorner.EMPTY, SubtileCorner.EMPTY, SubtileCorner.EMPTY],
        
        # FIXME: LEFT OFF HERE: ------------------
        # - Update these to include more h-internal/v-internal UNKNOWN values, now that
        #   I've added the simple interior connection annotation.
#        [SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90_90_CONVEX],
#        [SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90V],
#        [SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90H, SubtileCorner.EXT_90_90_CONVEX],
#        [SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90H, SubtileCorner.EXT_90V],
#        [SubtileCorner.EXT_90H, SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_INT_90_90_CONVEX],
#        [SubtileCorner.EXT_90V, SubtileCorner.EXT_INT_90_90_CONVEX, SubtileCorner.EXT_90_90_CONVEX],
#        [SubtileCorner.EXT_90H, SubtileCorner.EXT_90_90_CONVEX, SubtileCorner.EXT_90_90_CONCAVE],
#        [SubtileCorner.EXT_90V, SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90_90_CONVEX],
#
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90_90_CONCAVE],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90V, SubtileCorner.EXT_90_90_CONCAVE],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90H],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90V, SubtileCorner.EXT_90H],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_INT_90_90_CONVEX],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_INT_90_90_CONVEX, SubtileCorner.EXT_90_90_CONCAVE],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90V, SubtileCorner.EXT_INT_90_90_CONVEX],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_INT_90_90_CONVEX, SubtileCorner.EXT_90H],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_INT_90_90_CONVEX, SubtileCorner.EXT_INT_90_90_CONVEX],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_INT_90H],
#        [SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_INT_90V, SubtileCorner.EXT_90_90_CONCAVE],
        
        # FIXME: LEFT OFF HERE: --------------------
        # - Finish adding 90 cases.
        #   - All self-types that include an EXT_90_90_CONCAVE neighbor.
        #   - All int-based types.
#        [SubtileCorner., SubtileCorner., SubtileCorner.],
        
#        [SubtileCorner.EXT_90H, SubtileCorner.EXT_90H, SubtileCorner.EXT_90_90_CONCAVE],
#        [SubtileCorner.EXT_90V, SubtileCorner.EXT_90_90_CONCAVE, SubtileCorner.EXT_90V],
#
#        [SubtileCorner.EXT_90H, SubtileCorner.EXT_90H, SubtileCorner.EXT_90H],
#        [SubtileCorner.EXT_90V, SubtileCorner.EXT_90V, SubtileCorner.EXT_90V],
#        [SubtileCorner.EXT_90H, SubtileCorner.EXT_90H, SubtileCorner.EXT_INT_90H],
#        [SubtileCorner.EXT_90V, SubtileCorner.EXT_INT_90V, SubtileCorner.EXT_90V],
    ]
    
    # [self, h_internal, v_internal]
    var REQUIRED_45_QUADRANT_CORNER_TYPES := [
#        [SubtileCorner., SubtileCorner., SubtileCorner.],
    ]
    
    # [self, h_internal, v_internal]
    var REQUIRED_27_QUADRANT_CORNER_TYPES := [
#        [SubtileCorner., SubtileCorner., SubtileCorner.],
    ]
    
    var required_corner_types_collection := \
            [REQUIRED_90_QUADRANT_CORNER_TYPES]
    if tile.are_45_degree_subtiles_used:
        required_corner_types_collection.push_back(
                REQUIRED_45_QUADRANT_CORNER_TYPES)
    if tile.are_27_degree_subtiles_used:
        required_corner_types_collection.push_back(
                REQUIRED_27_QUADRANT_CORNER_TYPES)
    
    for corner_direction in CornerDirection.CORNERS:
        var direction_map: Dictionary = subtile_corner_types[corner_direction]
        for required_corner_types in required_corner_types_collection:
            for corner_types in required_corner_types:
                var self_corner_type: int = corner_types[0]
                var h_internal_corner_type: int = corner_types[1]
                var v_internal_corner_type: int = corner_types[2]
                assert(direction_map.has(self_corner_type))
                var self_map: Dictionary = direction_map[self_corner_type]
                assert(self_map.has(h_internal_corner_type))
                var h_internal_map: Dictionary = self_map[h_internal_corner_type]
                assert(h_internal_map.has(v_internal_corner_type))


static func _get_log_string(
        quadrant_position: Vector2,
        corner_direction: int,
        connection_direction: int,
        quadrant_size: int,
        image_path: String) -> String:
    return (
            "subtile=%s, " +
            "%s, " +
            "%s, " +
            "quadrant=%s, " +
            "image=%s"
        ) % [
            Sc.utils.get_vector_string(
                Sc.utils.floor_vector(quadrant_position / quadrant_size / 2.0),
                0),
            CornerDirection.get_string(corner_direction),
            ConnectionDirection.get_string(connection_direction),
            Sc.utils.get_vector_string(quadrant_position / quadrant_size, 0),
            image_path,
        ]
