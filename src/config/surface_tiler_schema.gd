tool
class_name SurfaceTilerSchema
extends FrameworkSchema


const _METADATA_SCRIPT := SurfaceTilerMetadata

const DEFAULT_TILESET_CONFIG := {
    recalculate_tileset = [TYPE_CUSTOM, RecalculateTilesetCustomProperty],
    tile_set = preload("res://addons/surface_tiler/src/demo_tileset.tres"),
    quadrant_size = 16,
    corner_match_tiles = [
        {
            outer_autotile_name = "autotile",
            inner_autotile_name = "__inner_autotile__",
            tileset_quadrants_path = \
                "res://addons/surface_tiler/assets/images/tileset_quadrants.png",
            tile_corner_type_annotations_path = \
                "res://addons/surface_tiler/assets/images/tileset_corner_type_annotations.png",
            subtile_collision_margin = 3.0,
            are_45_degree_subtiles_used = true,
            are_27_degree_subtiles_used = false,
        },
    ],
}

var _properties := {
    forces_convex_collision_shapes = true,
    allows_fallback_corner_matches = true,
    supports_runtime_autotiling = true,
    includes_intra_subtile_45_concave_cusps = true,
    
    corner_type_annotation_key_path = \
        "res://addons/surface_tiler/assets/images/corner_type_annotation_key.png",
    implicit_quadrant_connection_color = Color("ff3333"),
    
    annotations_parser_class = preload(
        "res://addons/surface_tiler/src/calculators/tile_annotations_parser.gd"),
    corner_calculator_class = preload(
        "res://addons/surface_tiler/src/calculators/subtile_target_corner_calculator.gd"),
    quadrant_calculator_class = preload(
        "res://addons/surface_tiler/src/calculators/subtile_target_quadrant_calculator.gd"),
    tileset_initializer_class = preload(
        "res://addons/surface_tiler/src/calculators/corner_match_tileset_initializer.gd"),
    shape_calculator_class = preload(
        "res://addons/surface_tiler/src/calculators/corner_match_tileset_shape_calculator.gd"),
    
    tilesets = [
        DEFAULT_TILESET_CONFIG,
    ],
}

var _additive_overrides := {
    ScaffolderSchema: {
        gui_manifest = {
            third_party_license_text = \
                    SurfaceTilerThirdPartyLicenses.TEXT + \
                    ScaffolderThirdPartyLicenses.TEXT,
        },
    },
}

var _subtractive_overrides := {}


func _init().(
        _METADATA_SCRIPT,
        _properties,
        _additive_overrides,
        _subtractive_overrides) -> void:
    pass
