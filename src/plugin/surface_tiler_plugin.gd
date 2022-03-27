tool
class_name SurfaceTilerPlugin
extends FrameworkPlugin


const _METADATA_SCRIPT := SurfaceTilerMetadata

const _CORNER_MATCH_TILEMAP_INSPECTOR_PLUGIN := \
        "res://addons/surface_tiler/src/plugin/corner_match_tilemap_inspector_plugin.gd"

var _corner_match_tilemap_inspector_plugin


func _init().(_METADATA_SCRIPT) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    assert(!is_instance_valid(_corner_match_tilemap_inspector_plugin))
    # FIXME: LEFT OFF HERE: ------------
    # - Can I preload this without circular deps?
    _corner_match_tilemap_inspector_plugin = \
            load(_CORNER_MATCH_TILEMAP_INSPECTOR_PLUGIN).new()
    add_inspector_plugin(_corner_match_tilemap_inspector_plugin)


func _exit_tree() -> void:
    remove_inspector_plugin(_corner_match_tilemap_inspector_plugin)
