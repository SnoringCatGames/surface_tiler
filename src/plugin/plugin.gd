tool
extends EditorPlugin


const _SURFACE_TILER_ICON := \
        preload("res://addons/surface_tiler/assets/images/surface_tiler.png")
const _SURFACE_TILER_MAIN_PANEL_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/surface_tiler_main_panel.tscn")

var main_panel: SurfaceTilerMainPanel
var corner_match_tilemap_inspector_plugin: CornerMatchTilemapInspectorPlugin


func _init() -> void:
    add_autoload_singleton("St", "res://addons/surface_tiler/src/config/st.gd")


func _enter_tree() -> void:
    corner_match_tilemap_inspector_plugin = \
            CornerMatchTilemapInspectorPlugin.new()
    add_inspector_plugin(corner_match_tilemap_inspector_plugin)
    
    main_panel = _SURFACE_TILER_MAIN_PANEL_SCENE.instance()
    get_editor_interface().get_editor_viewport().add_child(main_panel)
    
    make_visible(false)


func _exit_tree() -> void:
    remove_inspector_plugin(corner_match_tilemap_inspector_plugin)
    if is_instance_valid(main_panel):
        main_panel.queue_free()


func has_main_screen() -> bool:
    return true


func make_visible(visible: bool) -> void:
    if is_instance_valid(main_panel):
        main_panel.visible = visible


func get_plugin_name() -> String:
    return "SurfaceTiler"


func get_plugin_icon() -> Texture:
    return _SURFACE_TILER_ICON
