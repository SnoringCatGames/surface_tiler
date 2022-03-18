tool
class_name SurfaceTilerPlugin
extends FrameworkPlugin


const _SCHEMA_CLASS := SurfaceTilerManifestSchema

var _corner_match_tilemap_inspector_plugin: CornerMatchTilemapInspectorPlugin


func _init().(_SCHEMA_CLASS) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    _corner_match_tilemap_inspector_plugin = \
            CornerMatchTilemapInspectorPlugin.new()
    add_inspector_plugin(_corner_match_tilemap_inspector_plugin)


func _exit_tree() -> void:
    remove_inspector_plugin(_corner_match_tilemap_inspector_plugin)
