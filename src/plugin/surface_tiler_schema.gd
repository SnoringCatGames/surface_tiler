tool
class_name SurfaceTilerSchema
extends FrameworkSchema


const _DISPLAY_NAME := "Surface Tiler"
const _FOLDER_NAME := "surface_tiler"
const _AUTO_LOAD_NAME := "St"
const _AUTO_LOAD_DEPS := ["Sc"]
const _AUTO_LOAD_PATH := "res://addons/surface_tiler/src/config/st.gd"
const _ICON_DIRECTORY_PATH := "res://addons/surface_tiler/assets/images/"

const _PROPERTIES := {
    outer_autotile_name = [TYPE_STRING, "autotile"],
    inner_autotile_name = [TYPE_STRING, "__inner_autotile__"],
    forces_convex_collision_shapes = [TYPE_BOOL, true],
    allows_fallback_corner_matches = [TYPE_BOOL, true],
    supports_runtime_autotiling = [TYPE_BOOL, true],
    
    corner_type_annotation_key_path = [TYPE_STRING,
        "res://addons/surface_tiler/assets/images/corner_type_annotation_key.png"],
    implicit_quadrant_connection_color = [TYPE_COLOR, Color("ff3333")],
    
    annotations_parser_class = [TYPE_SCRIPT, preload(
        "res://addons/surface_tiler/src/calculators/tileset_annotations_parser.gd")],
    corner_calculator_class = [TYPE_SCRIPT, preload(
        "res://addons/surface_tiler/src/calculators/subtile_target_corner_calculator.gd")],
    quadrant_calculator_class = [TYPE_SCRIPT, preload(
        "res://addons/surface_tiler/src/calculators/subtile_target_quadrant_calculator.gd")],
    initializer_class = [TYPE_SCRIPT, preload(
        "res://addons/surface_tiler/src/calculators/corner_match_tileset_initializer.gd")],
    shape_calculator_class = [TYPE_SCRIPT, preload(
        "res://addons/surface_tiler/src/calculators/corner_match_tileset_shape_calculator.gd")],
    
    tilesets = [
        {
            recalculate_tileset = [TYPE_CUSTOM, RecalculateTilesetCustomProperty],
            tileset_quadrants_path = [TYPE_STRING,
                "res://addons/surface_tiler/assets/images/tileset_quadrants.png"],
            tileset_corner_type_annotations_path = [TYPE_STRING,
                "res://addons/surface_tiler/assets/images/tileset_corner_type_annotations.png"],
            tile_set = [TYPE_TILESET, null],
            quadrant_size = [TYPE_INT, 16],
            subtile_collision_margin = [TYPE_REAL, 3.0],
            are_45_degree_subtiles_used = [TYPE_BOOL, true],
            are_27_degree_subtiles_used = [TYPE_BOOL, false],
        },
    ],
}


func _init().(
        _DISPLAY_NAME,
        _FOLDER_NAME,
        _AUTO_LOAD_NAME,
        _AUTO_LOAD_DEPS,
        _AUTO_LOAD_PATH,
        _ICON_DIRECTORY_PATH,
        _PROPERTIES) -> void:
    pass
