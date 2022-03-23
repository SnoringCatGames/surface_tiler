tool
class_name SurfaceTilerPlugin
extends FrameworkPlugin


const _AUTO_LOAD_NAME := "St"
const _AUTO_LOAD_PATH := "res://addons/surface_tiler/src/config/st.gd"
const _SCHEMA_PATH := \
        "res://addons/surface_tiler/src/plugin/surface_tiler_schema.gd"

const _CORNER_MATCH_TILEMAP_INSPECTOR_PLUGIN := \
        "res://addons/surface_tiler/src/plugin/corner_match_tilemap_inspector_plugin.gd"

var _corner_match_tilemap_inspector_plugin


func _init().(
        _AUTO_LOAD_NAME,
        _AUTO_LOAD_PATH,
        _SCHEMA_PATH) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    # FIXME: LEFT OFF HERE: ------------
    # - Can I preload this without circular deps?
    _corner_match_tilemap_inspector_plugin = \
            load(_CORNER_MATCH_TILEMAP_INSPECTOR_PLUGIN).new()
    add_inspector_plugin(_corner_match_tilemap_inspector_plugin)


func _exit_tree() -> void:
    remove_inspector_plugin(_corner_match_tilemap_inspector_plugin)
