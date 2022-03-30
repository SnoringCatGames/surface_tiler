tool
class_name SurfaceTilerSchema
extends FrameworkSchema


const _METADATA_SCRIPT := SurfaceTilerMetadata

var _properties := {
    outer_autotile_name = "autotile",
    inner_autotile_name = "__inner_autotile__",
    forces_convex_collision_shapes = true,
    allows_fallback_corner_matches = true,
    supports_runtime_autotiling = true,
    
    corner_type_annotation_key_path = \
        "res://addons/surface_tiler/assets/images/corner_type_annotation_key.png",
    implicit_quadrant_connection_color = Color("ff3333"),
    
    annotations_parser_class = preload(
        "res://addons/surface_tiler/src/calculators/tileset_annotations_parser.gd"),
    corner_calculator_class = preload(
        "res://addons/surface_tiler/src/calculators/subtile_target_corner_calculator.gd"),
    quadrant_calculator_class = preload(
        "res://addons/surface_tiler/src/calculators/subtile_target_quadrant_calculator.gd"),
    initializer_class = preload(
        "res://addons/surface_tiler/src/calculators/corner_match_tileset_initializer.gd"),
    shape_calculator_class = preload(
        "res://addons/surface_tiler/src/calculators/corner_match_tileset_shape_calculator.gd"),
    
    tilesets = [
        {
            recalculate_tileset = [TYPE_CUSTOM, RecalculateTilesetCustomProperty],
            tileset_quadrants_path = \
                "res://addons/surface_tiler/assets/images/tileset_quadrants.png",
            tileset_corner_type_annotations_path = \
                "res://addons/surface_tiler/assets/images/tileset_corner_type_annotations.png",
            # FIXME: LEFT OFF HERE: ------------------- Make a default in the SurfaceTiler directory.
            tile_set = preload(
                "res://addons/squirrel_away/src/tiles/squirrel_away_tileset_with_many_angles.tres"),
            quadrant_size = 16,
            subtile_collision_margin = 3.0,
            are_45_degree_subtiles_used = true,
            are_27_degree_subtiles_used = false,
        },
    ],
}

var _additive_overrides := {}

var _subtractive_overrides := {}


func _init().(
        _METADATA_SCRIPT,
        _properties,
        _additive_overrides,
        _subtractive_overrides) -> void:
    pass
