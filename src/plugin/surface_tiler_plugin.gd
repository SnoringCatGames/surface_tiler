tool
class_name SurfaceTilerPlugin
extends FrameworkPlugin


const _DISPLAY_NAME := "SurfaceTiler"
const _ICON_DIRECTORY_PATH := "res://addons/surface_tiler/assets/images/"
const _AUTO_LOAD_NAME := "St"
const _AUTO_LOAD_PATH := "res://addons/surface_tiler/src/config/st.gd"

var _corner_match_tilemap_inspector_plugin: CornerMatchTilemapInspectorPlugin


func _init().(
        _DISPLAY_NAME,
        _ICON_DIRECTORY_PATH,
        _AUTO_LOAD_NAME,
        _AUTO_LOAD_PATH) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    _corner_match_tilemap_inspector_plugin = \
            CornerMatchTilemapInspectorPlugin.new()
    add_inspector_plugin(_corner_match_tilemap_inspector_plugin)


func _exit_tree() -> void:
    remove_inspector_plugin(_corner_match_tilemap_inspector_plugin)
