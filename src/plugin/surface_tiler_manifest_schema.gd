tool
class_name SurfaceTilerManifestSchema
extends FrameworkManifestSchema


func get_framework_display_name() -> String:
    return "SurfaceTiler"


func get_framework_folder_name() -> String:
    return "surface_tiler"


func get_properties() -> Dictionary:
    return {
        outer_autotile_name = TYPE_STRING,
        inner_autotile_name = TYPE_STRING,
        forces_convex_collision_shapes = TYPE_BOOL,
        allows_fallback_corner_matches = TYPE_BOOL,
        supports_runtime_autotiling = TYPE_BOOL,
        
        corner_type_annotation_key_path = TYPE_STRING,
        implicit_quadrant_connection_color = TYPE_COLOR,
        
        annotations_parser_class = TYPE_SCRIPT,
        corner_calculator_class = TYPE_SCRIPT,
        quadrant_calculator_class = TYPE_SCRIPT,
        initializer_class = TYPE_SCRIPT,
        shape_calculator_class = TYPE_SCRIPT,
        
        tilesets = [
            {
                tileset_quadrants_path = TYPE_STRING,
                tileset_corner_type_annotations_path = TYPE_STRING,
                tile_set = TYPE_TILESET,
                quadrant_size = TYPE_INT,
                subtile_collision_margin = TYPE_REAL,
                are_45_degree_subtiles_used = TYPE_BOOL,
                are_27_degree_subtiles_used = TYPE_BOOL,
            },
        ],
    }
