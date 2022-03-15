tool
extends EditorPlugin


# FIXME: LEFT OFF HERE: ------------------------------------------
# - Add support for configuring default manifest values within the
#   FrameworkManifestSchema subclass.
#   - E.g., SurfaceTilerManifestSchema should define default scripts and
#     tilesets to use based on the versions included in the library.
# - Create FrameworkManifestController:
#   - _create_property_controls
#     - Actually, move this to FrameworkManifestPanel.
#     - Try to re-use built-in Godot widgets if possible?
# - Refactor SurfaceTiler manifest to use the new plugin UI instead of GDScript
#   in SquirrelAway.
# - Create the multi-plugin scheme:
#   - Expect that Scaffolder will be the one core plugin that all the others depend upon.
#   - Expect that each individual plugin will register itself with Sc.
#   - Refactor things to work regardless of the order that AutoLoads are included.
#   - Expect that Scaffolder will force the order of plugin initialization to be as needed.
#     - Expect that each plugin will define a priority value.
#   - 


const _SURFACE_TILER_MAIN_PANEL_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/surface_tiler_main_panel.tscn")

var manifest_controller: FrameworkManifestController
var main_panel: SurfaceTilerMainPanel
var corner_match_tilemap_inspector_plugin: CornerMatchTilemapInspectorPlugin


func _init() -> void:
    add_autoload_singleton("St", "res://addons/surface_tiler/src/config/st.gd")
    
    var manifest_schema := SurfaceTilerManifestSchema.new()
    manifest_controller = FrameworkManifestController.new()
    manifest_controller.set_up(manifest_schema)


func _enter_tree() -> void:
    corner_match_tilemap_inspector_plugin = \
            CornerMatchTilemapInspectorPlugin.new()
    add_inspector_plugin(corner_match_tilemap_inspector_plugin)
    
    main_panel = _SURFACE_TILER_MAIN_PANEL_SCENE.instance()
    main_panel.set_up(manifest_controller)
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
    # TODO: We need better support for updating icon colors based on theme: 
    # https://github.com/godotengine/godot-proposals/issues/572
    var is_light_theme: bool = \
            get_editor_interface().get_editor_settings() \
                .get_setting("interface/theme/base_color").v > 0.5
    var theme := "light" if is_light_theme else "dark"
    var scale := get_editor_interface().get_editor_scale()
    var icon_path := \
            ("res://addons/surface_tiler/assets/images/" +
            "surface_tiler_%s_theme_%s.png") % [
                theme,
                str(scale),
            ]
    return load(icon_path) as Texture
