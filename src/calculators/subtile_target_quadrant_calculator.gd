tool
class_name SubtileTargetQuadrantCalculator
extends Node


const _QUADRANT_DEBUG_RESULTS_COUNT := 14


func get_quadrants(
        cell_position: Vector2,
        tile_id: int,
        tile: CornerMatchTile,
        tilemap: CornerMatchTilemap,
        logs_debug_info := false,
        logs_error_info := false) -> Array:
    if !Engine.editor_hint and \
            !St.supports_runtime_autotiling:
        return tile.error_quadrants
    
    var proximity := CellProximity.new(
            tilemap,
            tile,
            cell_position,
            tile_id)
    var target_corners := CellCorners.new(proximity)
    
    if !target_corners.get_are_corners_valid() and \
            logs_error_info:
        Sc.logger.warning(
            "Not all target corners are valid:\n%s\n%s" % [
            proximity.to_string(),
            target_corners.to_string(true),
        ])
        return tile.error_quadrants
    
    var quadrant_positions := []
    quadrant_positions.resize(4)
    
    for i in CornerDirection.CORNERS.size():
        var corner_direction: int = CornerDirection.CORNERS[i]
        
        var corner_types := ConnectionDirection \
                .CONNECTIONS_IN_QUADRANT_MATCH_PRIORITY_ORDER.duplicate()
        for j in corner_types.size():
            corner_types[j] = target_corners.get_corner_type(
                    corner_direction, corner_types[j])
        
        var debug_types := []
        # TODO: This is useful for debugging.
#        debug_types = _get_debug_types(
#                Vector2(8,45),
#                CornerDirection.BOTTOM_RIGHT,
#                corner_direction,
#                tile)
        
        var best_position_and_weight := _get_best_quadrant_match(
                tile.subtile_corner_types[corner_direction],
                corner_types,
                0,
                0,
                corner_direction,
                debug_types)
        var quadrant_position: Vector2 = best_position_and_weight[0]
        var quadrant_weight: float = best_position_and_weight[1]
        
        if logs_debug_info:
            Sc.logger.print("")
            Sc.logger.print(">>> get_quadrants: %s" % \
                    CornerDirection.get_string(corner_direction))
            Sc.logger.print(proximity.to_string())
            Sc.logger.print(target_corners.to_string(true))
            Sc.logger.print(_get_position_and_weight_results_string(
                    best_position_and_weight,
                    corner_direction))
            _print_subtile_corner_types(
                    corner_direction,
                    corner_types,
                    [target_corners.get_corner_type(corner_direction)],
                    tile.subtile_corner_types)
            Sc.logger.print(">>>")
            Sc.logger.print("")
        
        if quadrant_weight < \
                St.ACCEPTABLE_MATCH_WEIGHT_THRESHOLD and \
                logs_error_info:
            Sc.logger.warning(
                ("No matching quadrant was found: " +
                "%s, best_quadrant_match: [position=%s, weight=%s]\n%s\n%s") % [
                CornerDirection.get_string(corner_direction),
                str(quadrant_position),
                str(quadrant_weight),
                proximity.to_string(),
                target_corners.to_string(true),
            ])
            quadrant_position = tile.error_quadrants[i]
        
        quadrant_positions[i] = quadrant_position
    
    # If the matching quadrants represent the normal empty subtile, with no
    # interesting external neighbor matches, then we return Vector2.INF values,
    # so that the tilemap can clear the cell instead of assigning the empty
    # subtile.
    for i in quadrant_positions.size():
        if quadrant_positions[i] != tile.empty_quadrants[i]:
            return quadrant_positions
    return tile.CLEAR_QUADRANTS


# Array<Vector2, float, Dictionary, Dictionary, ...>
func _get_best_quadrant_match(
        corner_type_map_or_position,
        target_corner_types: Array,
        index: int,
        weight: float,
        corner_direction: int,
        debug_types := []) -> Array:
    var target_corner_type: int = target_corner_types[index]
    var iteration_weight_multiplier := _get_iteration_weight_multiplier(index)
    var connection_weight_multiplier_label := \
            _get_connection_weight_multiplier_label(index, corner_direction)
    
    var best_position_and_weight := [Vector2.INF, -INF]
    var best_weight_contribution := -INF
    var best_type := SubtileCorner.UNKNOWN
    var best_match_label := "-"
    
    if corner_type_map_or_position.has(target_corner_type):
        # Consider direct corner-type matches.
        
        var is_debug_match: bool = \
                debug_types.size() > index and \
                debug_types[index] == target_corner_type
        # Stop debugging in recursive iterations if this wasn't a match.
        var recursive_debug_types := \
                debug_types if \
                is_debug_match else \
                []
        
        var direct_match_corner_type_map_or_position = \
                corner_type_map_or_position[target_corner_type]
        var direct_match_weight_contribution := \
                iteration_weight_multiplier
        var connection_weight_multiplier := \
                CornerConnectionWeightMultipliers.get_multiplier(
                    target_corner_type,
                    connection_weight_multiplier_label)
        var direct_match_weight := \
                weight + \
                direct_match_weight_contribution * \
                connection_weight_multiplier
        
        var direct_match_position_and_weight: Array
        if direct_match_corner_type_map_or_position is Vector2:
            # Base case: We found a position.
            direct_match_position_and_weight = [
                direct_match_corner_type_map_or_position,
                direct_match_weight,
            ]
        else:
            # Recursive case: We found another mapping to consider.
            direct_match_position_and_weight = _get_best_quadrant_match(
                    direct_match_corner_type_map_or_position,
                    target_corner_types,
                    index + 1,
                    direct_match_weight,
                    corner_direction,
                    recursive_debug_types)
        
        best_position_and_weight = direct_match_position_and_weight
        best_weight_contribution = direct_match_weight_contribution
        best_type = target_corner_type
        best_match_label = "direct_match"
        
        if is_debug_match:
            Sc.logger.print("%s[%s] %s: %s, %s (%s)" % [
                Sc.utils.get_spaces(index * 2),
                str(index),
                St.get_subtile_corner_string(target_corner_type),
                "direct_match",
                direct_match_weight_contribution,
                direct_match_weight,
            ])
    
    if index == 0 or \
            !St.allows_fallback_corner_matches:
        best_position_and_weight.resize(_QUADRANT_DEBUG_RESULTS_COUNT)
        best_position_and_weight[index + 2] = {
            weight_contribution = best_weight_contribution,
            corner_type = best_type,
            match_label = best_match_label,
        }
        return best_position_and_weight
    
    if corner_type_map_or_position.has(SubtileCorner.UNKNOWN):
        # Consider the UNKNOWN value as a fallback.
        
        var is_debug_match: bool = \
                debug_types.size() > index and \
                debug_types[index] == SubtileCorner.UNKNOWN
        # Stop debugging in recursive iterations if this wasn't a match.
        var recursive_debug_types := \
                debug_types if \
                is_debug_match else \
                []
        
        var fallback_corner_type_map_or_position = \
                corner_type_map_or_position[SubtileCorner.UNKNOWN]
        var fallback_weight_contribution := \
                iteration_weight_multiplier * 0.1
        var fallback_weight := weight + fallback_weight_contribution
        
        var fallback_position_and_weight: Array
        if fallback_corner_type_map_or_position is Vector2:
            # Base case: We found a position.
            fallback_position_and_weight = [
                fallback_corner_type_map_or_position,
                fallback_weight,
            ]
        else:
            # Recursive case: We found another mapping to consider.
            fallback_position_and_weight = _get_best_quadrant_match(
                    fallback_corner_type_map_or_position,
                    target_corner_types,
                    index + 1,
                    fallback_weight,
                    corner_direction,
                    recursive_debug_types)
        
        if fallback_position_and_weight[1] > best_position_and_weight[1]:
            best_position_and_weight = fallback_position_and_weight
            best_weight_contribution = fallback_weight_contribution
            best_type = SubtileCorner.UNKNOWN
            best_match_label = "unknown_match"
        
        if is_debug_match:
            Sc.logger.print("%s[%s] %s: %s, %s (%s)" % [
                Sc.utils.get_spaces(index * 2),
                str(index),
                St.get_subtile_corner_string(SubtileCorner.UNKNOWN),
                "unknown_match",
                fallback_weight_contribution,
                fallback_weight,
            ])
    
    # Consider all explicitly configured fallbacks.
    var fallbacks_for_corner_type: Dictionary = \
            FallbackSubtileCorners.FALLBACKS[target_corner_type]
    for fallback_corner_type in fallbacks_for_corner_type:
        var fallback_corner_weight_multiplier := \
                _get_fallback_weight_multiplier(
                    fallbacks_for_corner_type[fallback_corner_type],
                    index)
        
        if fallback_corner_weight_multiplier <= 0.0:
            # Skip this fallback, since it is for the other direction.
            continue
        
        var connection_weight_multiplier := \
                CornerConnectionWeightMultipliers.get_multiplier(
                    fallback_corner_type,
                    connection_weight_multiplier_label)
        fallback_corner_weight_multiplier *= connection_weight_multiplier
        
        if fallback_corner_weight_multiplier < 1.0:
            # -   If the weight-multiplier is less than 1.0, then we should
            #     prefer mappings that use UNKNOWN values.
            # -   This offset ensures that a non-unknown fallback will
            #     counter the weight contributed by any match from the other
            #     direction.
            fallback_corner_weight_multiplier = \
                    (-1.0 - (1.0 - fallback_corner_weight_multiplier)) * 1.0
        else:
            fallback_corner_weight_multiplier *= 1.0
        
        if corner_type_map_or_position.has(fallback_corner_type):
            # There is a quadrant configured for this fallback corner-type.
            
            var is_debug_match: bool = \
                    debug_types.size() > index and \
                    debug_types[index] == fallback_corner_type
            # Stop debugging in recursive iterations if this wasn't a match.
            var recursive_debug_types := \
                    debug_types if \
                    is_debug_match else \
                    []
            
            var fallback_corner_type_map_or_position = \
                    corner_type_map_or_position[fallback_corner_type]
            var fallback_weight_contribution := \
                    iteration_weight_multiplier * \
                    fallback_corner_weight_multiplier
            var fallback_weight := weight + fallback_weight_contribution
            
            var fallback_position_and_weight: Array
            if fallback_corner_type_map_or_position is Vector2:
                # Base case: We found a position.
                fallback_position_and_weight = [
                    fallback_corner_type_map_or_position,
                    fallback_weight,
                ]
            else:
                # Recursive case: We found another mapping to consider.
                fallback_position_and_weight = _get_best_quadrant_match(
                        fallback_corner_type_map_or_position,
                        target_corner_types,
                        index + 1,
                        fallback_weight,
                        corner_direction,
                        recursive_debug_types)
            
            var fallback_match_label := \
                    "good_fallback_match" if \
                    fallback_weight_contribution > 0 else \
                    "bad_fallback_match"
            
            if fallback_position_and_weight[1] > best_position_and_weight[1]:
                best_position_and_weight = fallback_position_and_weight
                best_weight_contribution = fallback_weight_contribution
                best_type = fallback_corner_type
                best_match_label = fallback_match_label
            
            if is_debug_match:
                Sc.logger.print("%s[%s] %s: %s, %s (%s)" % [
                    Sc.utils.get_spaces(index * 2),
                    str(index),
                    St.get_subtile_corner_string(fallback_corner_type),
                    fallback_match_label,
                    fallback_weight_contribution,
                    fallback_weight,
                ])
    
    best_position_and_weight.resize(_QUADRANT_DEBUG_RESULTS_COUNT)
    best_position_and_weight[index + 2] = {
        weight_contribution = best_weight_contribution,
        corner_type = best_type,
        match_label = best_match_label,
    }
    return best_position_and_weight


func _get_debug_types(
        debug_subtile_position: Vector2,
        debug_corner_direction: int,
        current_corner_direction: int,
        tile: CornerMatchTile) -> Array:
    return St.annotations_parser.parse_quadrant(
                debug_subtile_position * tile.get_inner_cell_size().x * 2,
                debug_corner_direction,
                tile.get_inner_cell_size().x,
                tile._config.tile_corner_type_annotations_path,
                tile.corner_type_annotation_key) if \
            debug_subtile_position != Vector2.INF and \
                current_corner_direction == debug_corner_direction else \
            []


func _get_fallback_weight_multiplier(
        fallback_multipliers: Array,
        index: int) -> float:
    assert(index >= 0 and index <= 11)
    var is_external_iteration := index > 2 and index != 5
    var is_h_neighbor := index == 1 or index == 3 or index == 8
    var is_v_neighbor := index == 2 or index == 4 or index == 9
    var is_d_neighbor := \
            index == 5 or index == 6 or index == 7 or index == 10 or index == 11
    if is_external_iteration:
        if is_d_neighbor:
            return fallback_multipliers[5]
        elif is_h_neighbor:
            return fallback_multipliers[2]
        else:
            return fallback_multipliers[3]
    else:
        if is_d_neighbor:
            return fallback_multipliers[4]
        elif is_h_neighbor:
            return fallback_multipliers[0]
        else:
            return fallback_multipliers[1]


func _get_connection_weight_multiplier_label(
        index: int,
        corner_direction: int) -> String:
    assert(index >= 0 and index <= 11)
    var is_external_iteration := index > 2 and index != 5
    var is_h_neighbor := index == 1 or index == 3 or index == 8
    var is_v_neighbor := index == 2 or index == 4 or index == 9
    var is_d_neighbor := \
            index == 5 or index == 6 or index == 7 or index == 10 or index == 11
    var connection_weight_multiplier_label: String
    if is_d_neighbor:
        return "diagonal"
    elif is_h_neighbor:
        return "side"
    elif CornerDirection.get_is_top(corner_direction) == is_external_iteration:
        return "top"
    else:
        return "bottom"


func _get_iteration_weight_multiplier(index) -> float:
    var iteration_exponent: int
    match index:
        0: iteration_exponent = 0
        1, 2: iteration_exponent = 1
        3, 4, 5, 6, 7, 8, 9, 10, 11: iteration_exponent = 2
        _:
            Sc.logger.error(
                "SubtileTargetQuadrantCalculator._get_iteration_weight_multiplier")
    return 1000.0 / pow(1000.0,iteration_exponent)


func _print_subtile_corner_types(
        target_corner_direction: int,
        target_corner_types: Array,
        filter_connection_types: Array,
        subtile_corner_types: Dictionary) -> void:
    Sc.logger.print(">>>>> SubtileTargetQuadrantCalculator.subtile_corner_types")
    for corner_direction in Sc.utils.cascade_sort(subtile_corner_types.keys()):
        if target_corner_direction >= 0 and \
                target_corner_direction != corner_direction:
            continue
        Sc.logger.print(CornerDirection.get_string(corner_direction))
        _print_subtile_corner_types_recursively(
                subtile_corner_types[corner_direction],
                target_corner_types,
                filter_connection_types,
                0,
                target_corner_direction)
    Sc.logger.print(">>>>>")


func _print_subtile_corner_types_recursively(
        map: Dictionary,
        target_corner_types: Array,
        filter_connection_types: Array,
        index: int,
        target_corner_direction: int) -> void:
    if filter_connection_types.size() > index:
        var target_connection_type: int = filter_connection_types[index]
        if !map.has(target_connection_type):
            Sc.logger.warning(
                    ("subtile_corner_types does not contain the target " +
                    "connection type: " +
                    "target_type=%s, index=%s, target_types=%s") % [
                        St.get_subtile_corner_string(
                                target_connection_type),
                        str(index),
                        str(filter_connection_types),
                    ])
            return
        var next_value = map[target_connection_type]
        if next_value is Vector2:
            _print_subtile_connection_entry(
                    index,
                    target_corner_direction,
                    target_connection_type,
                    target_corner_types,
                    next_value)
        else:
            _print_subtile_connection_entry(
                    index,
                    target_corner_direction,
                    target_connection_type,
                    target_corner_types)
            _print_subtile_corner_types_recursively(
                    next_value,
                    target_corner_types,
                    filter_connection_types,
                    index + 1,
                    target_corner_direction)
    else:
        for connection_type in Sc.utils.cascade_sort(map.keys()):
            var next_value = map[connection_type]
            if next_value is Vector2:
                _print_subtile_connection_entry(
                        index,
                        target_corner_direction,
                        connection_type,
                        target_corner_types,
                        next_value)
            else:
                _print_subtile_connection_entry(
                        index,
                        target_corner_direction,
                        connection_type,
                        target_corner_types)
                _print_subtile_corner_types_recursively(
                        next_value,
                        target_corner_types,
                        filter_connection_types,
                        index + 1,
                        target_corner_direction)


func _print_subtile_connection_entry(
        index: int,
        target_corner_direction: int,
        connection_type: int,
        target_corner_types: Array,
        quadrant_coordinates := Vector2.INF) -> void:
    var target_connection_type: int = target_corner_types[index]
    var is_direct_match_to_target := connection_type == target_connection_type
    
    var fallback_weight := -INF
    if is_direct_match_to_target:
        fallback_weight = 1.0
    else:
        if FallbackSubtileCorners.FALLBACKS[target_connection_type] \
                .has(connection_type):
            fallback_weight = _get_fallback_weight_multiplier(
                    FallbackSubtileCorners.FALLBACKS \
                        [target_connection_type][connection_type],
                    index)
    
    var fallback_weight_string: String
    var connection_weight_string := ""
    if fallback_weight >= 0:
        fallback_weight_string = "%.2f" % fallback_weight
        
        var connection_weight_multiplier_label := \
                _get_connection_weight_multiplier_label(
                    index, target_corner_direction)
        var connection_weight_multiplier := \
                CornerConnectionWeightMultipliers.get_multiplier(
                    target_connection_type,
                    connection_weight_multiplier_label)
        connection_weight_string = \
                "[%.2f]" % connection_weight_multiplier
    else:
        fallback_weight_string = "--"
    
    var spaces := Sc.utils.get_spaces((index + 1) * 2)
    var quadrant_coordinates_string := \
            " => %s[%s]" % [
                str(Sc.utils.floor_vector(quadrant_coordinates / 2.0)),
                CornerDirection.get_string(target_corner_direction),
            ] if \
            quadrant_coordinates != Vector2.INF else \
            ""
    
    var message := "%s%s: %s%s [%s]%s" % [
        spaces,
        _get_neighbor_label_for_index(index),
        St.get_subtile_corner_string(connection_type),
        quadrant_coordinates_string,
        fallback_weight_string,
        connection_weight_string
    ]
    Sc.logger.print(message)


func _get_position_and_weight_results_string(
        position_and_weight: Array,
        corner_direction: int) -> String:
    var position_and_weight_result_strings := []
    position_and_weight_result_strings.push_back("subtile=%s[%s]" % [
        str(Sc.utils.floor_vector(position_and_weight[0] / 2.0)),
        CornerDirection.get_string(corner_direction),
    ])
    position_and_weight_result_strings.push_back(
            "w=" + str(position_and_weight[1]))
    for i in range(2,_QUADRANT_DEBUG_RESULTS_COUNT):
        var neighbor_result = position_and_weight[i]
        var contribution_string := \
                "NULL" if \
                neighbor_result == null else \
                "(%s, %s, %s)" % [
                    neighbor_result.match_label,
                    St.get_subtile_corner_string(
                        neighbor_result.corner_type),
                    str(neighbor_result.weight_contribution),
                ]
        position_and_weight_result_strings.push_back("%s=%s" % [
                _get_neighbor_label_for_index(i - 2),
                contribution_string,
            ])
    return "quadrant_match(\n    %s\n)" % \
            Sc.utils.join(position_and_weight_result_strings, ",\n    ")


func _get_neighbor_label_for_index(index: int) -> String:
    var neighbor_labels := [
        "Self",
        "H-internal",
        "V-internal",
        "H-external",
        "V-external",
        "Diagonal-internal",
        "H-diag-external",
        "V-diag-external",
        "H2-external",
        "V2-external",
        "H2-diag-external",
        "V2-diag-external",
    ]
    return neighbor_labels[index]
    
