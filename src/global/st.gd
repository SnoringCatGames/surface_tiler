tool
class_name StInterface
extends FrameworkGlobal
## FIXME: LEFT OFF HERE: -------------- Update docs.
## -   This is a global singleton that defines a bunch of Surfacer
##     parameters.[br]
## -   All of these parameters can be configured when bootstrapping the
##     app.[br]
## -   You will need to provide an `app_manifest` dictionary which defines some
##     of these parameters.[br]
## -   Define `Su` as an AutoLoad (in Project Settings).[br]
## -   "St" is short for "SurfaceTiler".[br]


# TODO: Add support for:
# - !forces_convex_collision_shapes
# - Multiple autotiling 90/45/27-tile-collections.
# - One-way collisions
# - Configuring z-index


# --- Constants ---

const _SCHEMA_PATH := \
        "res://addons/surface_tiler/src/config/surface_tiler_schema.gd"

# FIXME: LEFT OFF HERE: ---------------------------------
var ACCEPTABLE_MATCH_WEIGHT_THRESHOLD := 1.0

# FIXME: LEFT OFF HERE: --------------------------------- Remove these?
# NOTE: These values should be between 0 and 1, exclusive.
var SUBTILE_DEPTH_TO_UNMATCHED_CORNER_WEIGHT_MULTIPLIER := {
    # NOTE: We need UNKNOWNs to match with high weight, so that a mapping
    #       without external corners will rank higher than a mapping with the
    #       wrong external corners.
    SubtileDepth.UNKNOWN: {
        SubtileDepth.UNKNOWN: 0.9,
        SubtileDepth.EXTERIOR: 0.9,
        SubtileDepth.EXT_INT: 0.9,
        SubtileDepth.INT_EXT: 0.9,
        SubtileDepth.FULLY_INTERIOR: 0.9,
    },
    SubtileDepth.EXTERIOR: {
        SubtileDepth.UNKNOWN: 0.9,
        SubtileDepth.EXTERIOR: 0.8,
        SubtileDepth.EXT_INT: 0.5,
        SubtileDepth.INT_EXT: 0.2,
        SubtileDepth.FULLY_INTERIOR: 0.12,
    },
    SubtileDepth.EXT_INT: {
        SubtileDepth.UNKNOWN: 0.9,
        SubtileDepth.EXTERIOR: 0.5,
        SubtileDepth.EXT_INT: 0.7,
        SubtileDepth.INT_EXT: 0.3,
        SubtileDepth.FULLY_INTERIOR: 0.16,
    },
    SubtileDepth.INT_EXT: {
        SubtileDepth.UNKNOWN: 0.9,
        SubtileDepth.EXTERIOR: 0.2,
        SubtileDepth.EXT_INT: 0.3,
        SubtileDepth.INT_EXT: 0.4,
        SubtileDepth.FULLY_INTERIOR: 0.25,
    },
    SubtileDepth.FULLY_INTERIOR: {
        SubtileDepth.UNKNOWN: 0.9,
        SubtileDepth.EXTERIOR: 0.12,
        SubtileDepth.EXT_INT: 0.16,
        SubtileDepth.INT_EXT: 0.25,
        SubtileDepth.FULLY_INTERIOR: 0.3,
    },
}

# --- SurfaceTiler global state ---

var are_models_initialized := false

# Dictionary<int, String>
var SUBTILE_CORNER_TYPE_VALUE_TO_KEY: Dictionary

var forces_convex_collision_shapes: bool

# -   If true, the autotiling logic will try to find the best match given which
#     subtiles are available.
#     -   The tile-set author can then omit many of the possible subtile angle
#         combinations.
#     -   This may impact performance if many tiles are updated frequently at
#         run time.
# -   If false, the autotiling logic will assume all possible subtile angle
#         combinations are defined.
#     -   The tile-set author then needs to draw many more subtile angle
#         combinations.
#     -   Only exact quadrant corner-type matches will be used.
#     -   If an exact match isn't defined, then the error-indicator quadrant
#         will be used.
#     -   The level author can then see the error-indicator and change their
#         level topography to instead use whichever subtiles are available.
var allows_fallback_corner_matches: bool

# -   If false, then custom corner-match autotiling behavior will not happen at
#     runtime, and will only happen when editing within the scene editor.
var supports_runtime_autotiling: bool

var includes_intra_subtile_45_concave_cusps: bool

var corner_type_annotation_key_path: String

var implicit_quadrant_connection_color: Color

var annotations_parser: TileAnnotationsParser
var annotations_recorder: TileAnnotationsRecorder
var corner_calculator: SubtileTargetCornerCalculator
var quadrant_calculator: SubtileTargetQuadrantCalculator
var shape_calculator: CornerMatchTilesetShapeCalculator
var initializer: CornerMatchTilesetInitializer

# Array<{
#   tile_set: CornerMatchTileset,
#   quadrant_size: int,
#   corner_match_tiles: [{
#     outer_autotile_name: String,
#     inner_autotile_name: String,
#     tileset_quadrants_path: String,
#     tile_corner_type_annotations_path: String,
#     subtile_collision_margin: float,
#     are_45_degree_subtiles_used: bool,
#     are_27_degree_subtiles_used: bool,
# }]>
var tileset_configs: Array

# ---


func _init().(_SCHEMA_PATH) -> void:
    pass


func _destroy() -> void:
    ._destroy()
    manifest = {}
    are_models_initialized = false
    tileset_configs = []


func _get_members_to_destroy() -> Array:
    return [
        annotations_parser,
        annotations_recorder,
        corner_calculator,
        quadrant_calculator,
        shape_calculator,
        initializer,
    ]


func _parse_manifest() -> void:
    self.forces_convex_collision_shapes = \
            manifest.forces_convex_collision_shapes
    self.allows_fallback_corner_matches = \
            manifest.allows_fallback_corner_matches
    self.supports_runtime_autotiling = manifest.supports_runtime_autotiling
    
    self.includes_intra_subtile_45_concave_cusps = \
            manifest.includes_intra_subtile_45_concave_cusps
    
    self.corner_type_annotation_key_path = \
            manifest.corner_type_annotation_key_path
    self.implicit_quadrant_connection_color = \
            manifest.implicit_quadrant_connection_color
    
    assert(manifest.tilesets is Array)
    self.tileset_configs = manifest.tilesets
    for tileset_config in manifest.tilesets:
        assert(tileset_config.tile_set is CornerMatchTileset)
        assert(Sc.utils.is_num(tileset_config.quadrant_size))
        tileset_config.tile_set._config = tileset_config
        tileset_config.tile_set.subtile_size = \
                tileset_config.quadrant_size * Vector2.ONE * 2.0
        
        for tile_config in tileset_config.corner_match_tiles:
            assert(tile_config.outer_autotile_name is String)
            assert(tile_config.inner_autotile_name is String)
            assert(tile_config.tileset_quadrants_path is String)
            assert(tile_config.tile_corner_type_annotations_path is String)
            assert(Sc.utils.is_num(tile_config.subtile_collision_margin))
            assert(tile_config.are_45_degree_subtiles_used is bool)
            assert(tile_config.are_27_degree_subtiles_used is bool)
            var tile := CornerMatchTile.new()
            tile._config = tile_config
            tile_config.tile = tile
            tile.tile_set = tileset_config.tile_set
    
    _parse_subtile_corner_key_values()


func _instantiate_sub_modules() -> void:
    if !supports_runtime_autotiling and \
            Engine.editor_hint:
        return
    
    if manifest.has("annotations_parser_class"):
        self.annotations_parser = manifest.annotations_parser_class.new()
        assert(self.annotations_parser is TileAnnotationsParser)
    else:
        self.annotations_parser = TileAnnotationsParser.new()
    self.add_child(annotations_parser)
    
    self.annotations_recorder = TileAnnotationsRecorder.new()
    self.add_child(annotations_recorder)
    
    if manifest.has("corner_calculator_class"):
        self.corner_calculator = manifest.corner_calculator_class.new()
        assert(self.corner_calculator is SubtileTargetCornerCalculator)
    else:
        self.corner_calculator = SubtileTargetCornerCalculator.new()
    self.add_child(corner_calculator)
    
    if manifest.has("quadrant_calculator_class"):
        self.quadrant_calculator = manifest.quadrant_calculator_class.new()
        assert(self.quadrant_calculator is SubtileTargetQuadrantCalculator)
    else:
        self.quadrant_calculator = SubtileTargetQuadrantCalculator.new()
    self.add_child(quadrant_calculator)
    
    if manifest.has("shape_calculator_class"):
        self.shape_calculator = manifest.shape_calculator_class.new()
        assert(self.shape_calculator is CornerMatchTilesetShapeCalculator)
    else:
        self.shape_calculator = CornerMatchTilesetShapeCalculator.new()
    self.add_child(shape_calculator)
    
    if manifest.has("tileset_initializer_class"):
        self.initializer = manifest.tileset_initializer_class.new()
        assert(self.initializer is CornerMatchTilesetInitializer)
    else:
        self.initializer = CornerMatchTilesetInitializer.new()
    self.add_child(initializer)


func _configure_sub_modules() -> void:
    pass


func initialize_models(includes_tilesets := false) -> void:
    if !supports_runtime_autotiling and \
            Engine.editor_hint:
        return
    
    _validate_subtile_corner_to_depth()
    _validate_subtile_depth_to_unmatched_corner_weight_multiplier()
    _parse_fallback_corner_types()
    
    if includes_tilesets:
        for tileset_config in tileset_configs:
            initializer.initialize_tileset(tileset_config.tile_set)
    
    are_models_initialized = true


func get_subtile_corner_string(type: int) -> String:
    return SUBTILE_CORNER_TYPE_VALUE_TO_KEY[type]


# This hacky function exists for a couple reasons:
# -   We need to be able to use the anonymous enum syntax for these
#     SubtileCorner values, so that tile-set authors don't need to include so
#     many extra characters for the enum prefix in their GDScript
#     configurations.
# -   We need to be able to print the key for a given enum value, so that a
#     human can debug what's going on.
# -   We need to be able to iterate over all possible enum values.
# -   GDScript's type system doesn't allow referencing the name of a class from
#     within that class.
func _parse_subtile_corner_key_values() -> void:
    if !Engine.editor_hint and \
            !supports_runtime_autotiling:
        return
    
    var constants := SubtileCorner.get_script_constant_map()
    for key in constants:
        SUBTILE_CORNER_TYPE_VALUE_TO_KEY[constants[key]] = key


func _validate_subtile_corner_to_depth() -> void:
    assert(SUBTILE_CORNER_TYPE_VALUE_TO_KEY.size() == \
            SubtileCornerToDepth.CORNERS_TO_DEPTHS.size())
    for corner_type in SUBTILE_CORNER_TYPE_VALUE_TO_KEY:
        assert(SubtileCornerToDepth.CORNERS_TO_DEPTHS.has(corner_type))
        assert(SubtileCornerToDepth.CORNERS_TO_DEPTHS[corner_type] is int)


func _validate_subtile_depth_to_unmatched_corner_weight_multiplier() -> void:
    for weight_multipliers in \
            SUBTILE_DEPTH_TO_UNMATCHED_CORNER_WEIGHT_MULTIPLIER.values():
        for weight_multiplier in weight_multipliers.values():
            assert(weight_multiplier > 0.0 and weight_multiplier < 1.0)


func _parse_fallback_corner_types() -> void:
    _validate_fallback_subtile_corners()
    _populate_abridged_fallback_multipliers()
    _record_reverse_fallbacks()
    _record_transitive_fallbacks()
    _validate_connection_weight_multipliers()
    _populate_connection_weight_multipliers_with_fallbacks()
#    _print_fallbacks()
#    _print_connection_weight_multipliers()


func _validate_fallback_subtile_corners() -> void:
    # Validate FallbackSubtileCorners.
    assert(SUBTILE_CORNER_TYPE_VALUE_TO_KEY.size() == \
            FallbackSubtileCorners.FALLBACKS.size())
    for corner_type in SUBTILE_CORNER_TYPE_VALUE_TO_KEY:
        assert(FallbackSubtileCorners.FALLBACKS.has(corner_type))
        assert(FallbackSubtileCorners.FALLBACKS[corner_type] is Dictionary)
        for fallback_type in FallbackSubtileCorners.FALLBACKS[corner_type]:
            var fallback_multipliers: Array = \
                    FallbackSubtileCorners.FALLBACKS[corner_type][fallback_type]
            assert(fallback_multipliers is Array)
            assert(fallback_multipliers.size() == 2 or \
                    fallback_multipliers.size() == 4 or \
                    fallback_multipliers.size() == 6)
            for multiplier in fallback_multipliers:
                assert(Sc.utils.is_num(multiplier))
                assert(multiplier >= 0.0 and multiplier <= 1.0)


func _populate_abridged_fallback_multipliers() -> void:
    for corner_type in FallbackSubtileCorners.FALLBACKS:
        for fallback_type in FallbackSubtileCorners.FALLBACKS[corner_type]:
            var fallback_multipliers: Array = \
                    FallbackSubtileCorners.FALLBACKS[corner_type][fallback_type]
            if fallback_multipliers.size() == 2:
                fallback_multipliers.resize(6)
                fallback_multipliers[2] = fallback_multipliers[1]
                fallback_multipliers[3] = fallback_multipliers[0]
                fallback_multipliers[4] = 0.0
                fallback_multipliers[5] = 0.0
            elif fallback_multipliers.size() == 4:
                fallback_multipliers.resize(6)
                fallback_multipliers[4] = 0.0
                fallback_multipliers[5] = 0.0


func _record_reverse_fallbacks() -> void:
    for corner_type in FallbackSubtileCorners.FALLBACKS:
        var forward_map: Dictionary = \
                FallbackSubtileCorners.FALLBACKS[corner_type]
        for fallback_type in forward_map:
            var reverse_map: Dictionary = \
                    FallbackSubtileCorners.FALLBACKS[fallback_type]
            if !reverse_map.has(corner_type):
                reverse_map[corner_type] = forward_map[fallback_type]
            var forward_multipliers: Array = forward_map[fallback_type]
            var reverse_multipliers: Array = reverse_map[corner_type]
            for i in 6:
                assert(forward_multipliers[i] == reverse_multipliers[i],
                        ("FallbackSubtileCorners: Two corner-types are " +
                        "mapped to each other with different multipliers: " +
                        "forward_type=%s, " +
                        "reverse_type=%s, " +
                        "index=%s, " +
                        "forward_multiplier=%s, " +
                        "reverse_multiplier=%s") % [
                            get_subtile_corner_string(corner_type),
                            get_subtile_corner_string(fallback_type),
                            i,
                            forward_multipliers[i],
                            reverse_multipliers[i],
                        ])


func _record_transitive_fallbacks() -> void:
    var exclusion_set := {}
    for corner_type in FallbackSubtileCorners.FALLBACKS:
        exclusion_set[corner_type] = true
        for fallback_type in FallbackSubtileCorners.FALLBACKS[corner_type]:
            var multipliers: Array = \
                    FallbackSubtileCorners.FALLBACKS[corner_type][fallback_type]
            _record_transitive_fallbacks_recursively(
                    fallback_type,
                    corner_type,
                    multipliers[0],
                    multipliers[1],
                    multipliers[2],
                    multipliers[3],
                    multipliers[4],
                    multipliers[5],
                    exclusion_set)
        exclusion_set[corner_type] = false


func _record_transitive_fallbacks_recursively(
        corner_type: int,
        transitive_basis_type: int,
        h_internal_multiplier: float,
        v_internal_multiplier: float,
        h_external_multiplier: float,
        v_external_multiplier: float,
        d_internal_multiplier: float,
        d_external_multiplier: float,
        exclusion_set: Dictionary) -> void:
    var transitive_basis_map: Dictionary = \
            FallbackSubtileCorners.FALLBACKS[transitive_basis_type]
    var current_map: Dictionary = FallbackSubtileCorners.FALLBACKS[corner_type]
    
    # Create a new transitive mapping, if it didn't exist already.
    if !transitive_basis_map.has(corner_type):
        transitive_basis_map[corner_type] = [
            h_internal_multiplier,
            v_internal_multiplier,
            h_external_multiplier,
            v_external_multiplier,
            d_internal_multiplier,
            d_external_multiplier,
        ]
    else:
        # Update the multipliers for the transitive mapping to be the max of the
        # previously-recorded and current-transitive values.
        var multipliers: Array = transitive_basis_map[corner_type]
        h_internal_multiplier = max(multipliers[0], h_internal_multiplier)
        v_internal_multiplier = max(multipliers[1], v_internal_multiplier)
        h_external_multiplier = max(multipliers[2], h_external_multiplier)
        v_external_multiplier = max(multipliers[3], v_external_multiplier)
        d_internal_multiplier = max(multipliers[4], d_internal_multiplier)
        d_external_multiplier = max(multipliers[5], d_external_multiplier)
        multipliers[0] = h_internal_multiplier
        multipliers[1] = v_internal_multiplier
        multipliers[2] = h_external_multiplier
        multipliers[3] = v_external_multiplier
        multipliers[4] = d_internal_multiplier
        multipliers[5] = d_external_multiplier
    
    assert(!exclusion_set.has(corner_type) or !exclusion_set[corner_type])
    
    exclusion_set[corner_type] = true
    
    for fallback_type in current_map:
        if exclusion_set.has(fallback_type) and \
                exclusion_set[fallback_type]:
            # We're already considering this type in the current transitive
            # chain.
            continue
        
        # Calculate the transitive multipliers.
        var fallback_multipliers: Array = current_map[fallback_type]
        var transitive_h_internal_multiplier := min(
                h_internal_multiplier,
                fallback_multipliers[0])
        var transitive_v_internal_multiplier := min(
                v_internal_multiplier,
                fallback_multipliers[1])
        var transitive_h_external_multiplier := min(
                h_external_multiplier,
                fallback_multipliers[2])
        var transitive_v_external_multiplier := min(
                v_external_multiplier,
                fallback_multipliers[3])
        var transitive_d_internal_multiplier := min(
                d_internal_multiplier,
                fallback_multipliers[4])
        var transitive_d_external_multiplier := min(
                d_external_multiplier,
                fallback_multipliers[5])
        
        if transitive_h_internal_multiplier <= 0.0 and \
                transitive_v_internal_multiplier <= 0.0 and \
                transitive_h_external_multiplier <= 0.0 and \
                transitive_v_external_multiplier <= 0.0 and \
                transitive_d_internal_multiplier <= 0.0 and \
                transitive_d_external_multiplier <= 0.0:
            # There is no transitive fallback weight to propagate.
            continue
        
        if transitive_basis_map.has(fallback_type):
            var preexisting_multipliers: Array = \
                    transitive_basis_map[fallback_type]
            if preexisting_multipliers[0] >= \
                        transitive_h_internal_multiplier and \
                    preexisting_multipliers[1] >= \
                        transitive_v_internal_multiplier and \
                    preexisting_multipliers[2] >= \
                        transitive_h_external_multiplier and \
                    preexisting_multipliers[3] >= \
                        transitive_v_external_multiplier and \
                    preexisting_multipliers[4] >= \
                        transitive_d_internal_multiplier and \
                    preexisting_multipliers[5] >= \
                        transitive_d_external_multiplier:
                # This transitive fallback is already mapped with at least the
                # same weights.
                continue
        
        _record_transitive_fallbacks_recursively(
                fallback_type,
                transitive_basis_type,
                transitive_h_internal_multiplier,
                transitive_v_internal_multiplier,
                transitive_h_external_multiplier,
                transitive_v_external_multiplier,
                transitive_d_internal_multiplier,
                transitive_d_external_multiplier,
                exclusion_set)
    
    exclusion_set[corner_type] = false


func _validate_connection_weight_multipliers() -> void:
    for value in CornerConnectionWeightMultipliers.MULTIPLIERS.values():
        assert(Sc.utils.is_num(value) or value is Dictionary)
        if value is Dictionary:
            assert(value.has("top") and Sc.utils.is_num(value.top))
            assert(value.has("bottom") and Sc.utils.is_num(value.bottom))
            assert(value.has("side") and Sc.utils.is_num(value.side))
            assert(value.has("diagonal") and Sc.utils.is_num(value.diagonal))
            assert(value.top > 0.0 and value.top <= 1.0)
            assert(value.bottom > 0.0 and value.bottom <= 1.0)
            assert(value.side > 0.0 and value.side <= 1.0)
            assert(value.diagonal > 0.0 and value.diagonal <= 1.0)


func _populate_connection_weight_multipliers_with_fallbacks() -> void:
    var connection_weight_multipliers: Dictionary = \
            CornerConnectionWeightMultipliers.MULTIPLIERS
    for corner_type in FallbackSubtileCorners.FALLBACKS:
        if connection_weight_multipliers.has(corner_type):
            # Don't modify preexisting multipliers.
            continue
        
        var min_bottom := INF
        var min_top := INF
        var min_side := INF
        var min_diagonal := INF
        
        for fallback_type in FallbackSubtileCorners.FALLBACKS[corner_type]:
            if connection_weight_multipliers.has(fallback_type):
                var value = connection_weight_multipliers[fallback_type]
                
                var fallback_multiplier_top: float
                var fallback_multiplier_bottom: float
                var fallback_multiplier_side: float
                var fallback_multiplier_diagonal: float
                if value is Dictionary:
                    fallback_multiplier_top = value.top
                    fallback_multiplier_bottom = value.bottom
                    fallback_multiplier_side = value.side
                    fallback_multiplier_diagonal = value.diagonal
                else:
                    fallback_multiplier_top = value
                    fallback_multiplier_bottom = value
                    fallback_multiplier_side = value
                    fallback_multiplier_diagonal = value
                
                var fallback_multipliers: Array = \
                        FallbackSubtileCorners.FALLBACKS \
                            [corner_type][fallback_type]
                var is_good_horizontal_fallback: bool = \
                        fallback_multipliers[0] == 1.0 or \
                        fallback_multipliers[2] == 1.0
                var is_good_vertical_fallback: bool = \
                        fallback_multipliers[1] == 1.0 or \
                        fallback_multipliers[3] == 1.0
                var is_good_diagonal_fallback: bool = \
                        fallback_multipliers[4] == 1.0 or \
                        fallback_multipliers[5] == 1.0
#                var is_good_horizontal_fallback: bool = \
#                        fallback_multipliers[0] == 1.0
#                var is_good_vertical_fallback: bool = \
#                        fallback_multipliers[1] == 1.0
#                var is_good_diagonal_fallback: bool = \
#                        fallback_multipliers[4] == 1.0
                
                if is_good_vertical_fallback:
                    min_top = min(min_top, fallback_multiplier_top)
                    min_bottom = min(min_bottom, fallback_multiplier_bottom)
                if is_good_horizontal_fallback:
                    min_side = min(min_side, fallback_multiplier_side)
                if is_good_diagonal_fallback:
                    min_diagonal = min(min_diagonal, fallback_multiplier_diagonal)
        
        if min_top <= 1.0 or \
                min_bottom <= 1.0 or \
                min_side <= 1.0 or \
                min_diagonal <= 1.0:
            if min_top > 1.0:
                min_top = 1.0
            if min_bottom > 1.0:
                min_bottom = 1.0
            if min_side > 1.0:
                min_side = 1.0
            if min_diagonal > 1.0:
                min_diagonal = 1.0
            
            if min_top == min_bottom and \
                    min_top == min_side and \
                    min_top == min_diagonal:
                connection_weight_multipliers[corner_type] = min_top
            else:
                connection_weight_multipliers[corner_type] = {
                    top = min_top,
                    bottom = min_bottom,
                    side = min_side,
                    diagonal = min_diagonal,
                }


func _print_fallbacks() -> void:
    print("")
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print(">>> SUBTILE CORNER-TYPE FALLBACKS >>>")
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    for corner_type in Sc.utils.cascade_sort(
            FallbackSubtileCorners.FALLBACKS.keys()):
        print("%s:" % get_subtile_corner_string(corner_type))
        for fallback_type in Sc.utils.cascade_sort(
                FallbackSubtileCorners.FALLBACKS[corner_type].keys()):
            var multipliers: Array = \
                    FallbackSubtileCorners.FALLBACKS[corner_type][fallback_type]
            print(("    %s [" +
                    "h_internal=%s, " +
                    "v_internal=%s, " +
                    "h_external=%s, " +
                    "v_external=%s, " +
                    "d_internal=%s, " +
                    "d_external=%s]") % [
                Sc.utils.pad_string(
                        get_subtile_corner_string(fallback_type) + ":",
                        56,
                        true,
                        true),
                str(multipliers[0]),
                str(multipliers[1]),
                str(multipliers[2]),
                str(multipliers[3]),
                str(multipliers[4]),
                str(multipliers[5]),
            ])
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print("")


func _print_connection_weight_multipliers() -> void:
    print("")
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print(">>> SUBTILE CONNECTION-WEIGHT MULTIPLIERS >>>")
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    for corner_type in Sc.utils.cascade_sort(
            CornerConnectionWeightMultipliers.MULTIPLIERS.keys()):
        var value = CornerConnectionWeightMultipliers.MULTIPLIERS[corner_type]
        if value is Dictionary:
            print("%s: [top=%s, bottom=%s, side=%s, diagonal=%s]" % [
                get_subtile_corner_string(corner_type),
                str(value.top),
                str(value.bottom),
                str(value.side),
                str(value.diagonal),
            ])
        else:
            print("%s: %s" % [
                get_subtile_corner_string(corner_type),
                str(value),
            ])
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print("")
