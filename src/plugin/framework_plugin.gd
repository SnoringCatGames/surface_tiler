tool
class_name FrameworkPlugin
extends EditorPlugin


# FIXME: LEFT OFF HERE: ------------------------------------------
# - Registering:
#   - Include a new standard flow for getting framework manifest:
#     - Call controller.set_up() to instantiate the manifest.
# 
# - Refactor main-panel to be generic for any plugin.
# - Add logic to adapt the main-screen content depending on which frameworks are present:
#   - If more than one, then show a tab list across the top for switching between them?
#   - List all framework manifest editors in a big vertical list with accordions
#     to collapse each framework.
#   - Create a manifest/config new icon for the main-screen tab.
#     - Just a simple settings-list/menu/horizontal-lines icon.
#   - Create clean icons for Scaffolder, Surfacer, SurfaceTiler, SurfaceParser,
#     Gooier, and game (use a simple star).
#     - Create the various different sizes and colors for each of these.
#     - Show these in the configuration-main-screen accordion headers for each
#       framework.
# - Add a button for resetting all global manifest and autoload state.
# - Refactor SurfaceTiler manifest to use the new plugin UI instead of GDScript
#   in SquirrelAway.
# - Create the multi-plugin scheme:
#   - Expect that Scaffolder will be the one core plugin that all the others depend upon.
#   - Expect that each individual plugin will register itself with Sc.
#   - Refactor things to work regardless of the order that AutoLoads are included.
#   - Expect that Scaffolder will force the order of plugin initialization to be as needed.
#     - Expect that each plugin will define a priority value.
#   - 

var _display_name: String
var _icon_directory_path: String
var _auto_load_name: String
var _auto_load_path: String
var _main_panel_scene: PackedScene

var _is_ready := false

var _auto_load: FrameworkConfig
var _main_panel: SurfaceTilerMainPanel


func _init(
        display_name: String,
        icon_directory_path: String,
        auto_load_name: String,
        auto_load_path: String,
        main_panel_scene: PackedScene) -> void:
    self._display_name = display_name
    self._icon_directory_path = icon_directory_path
    self._auto_load_name = auto_load_name
    self._auto_load_path = auto_load_path
    self._main_panel_scene = main_panel_scene


func _ready() -> void:
    _is_ready = true
    _create_auto_load()
    _validate_editor_icons()
    _set_up()


func _get_is_ready() -> bool:
    return _is_ready and \
            is_inside_tree() and \
            is_instance_valid(_auto_load) and \
            _auto_load.is_initialized


func _create_auto_load() -> void:
    add_autoload_singleton(_auto_load_name, _auto_load_path)
    call_deferred("_connect_auto_load")


func _connect_auto_load() -> void:
    self._auto_load = get_node("/root/" + _auto_load_name)
    _auto_load.connect("initialized", self, "_on_framework_initialized")
    if _auto_load.is_initialized:
        _on_framework_initialized()


func _on_framework_initialized() -> void:
    _set_up()


func _enter_tree() -> void:
    _set_up()


func _set_up() -> void:
    if !_get_is_ready():
        return
    
    if !is_instance_valid(_auto_load.manifest_controller):
        _auto_load.manifest_controller = FrameworkManifestController.new()
        _auto_load.manifest_controller.set_up(SurfaceTilerManifestSchema.new())
        
        # FIXME: --------------------- REMOVE
        _auto_load._register_manifest_TMP(_auto_load.manifest)
    
    _main_panel = _main_panel_scene.instance()
    get_editor_interface().get_editor_viewport().add_child(_main_panel)
    
    make_visible(false)


func _exit_tree() -> void:
    if is_instance_valid(_main_panel):
        _main_panel.queue_free()


func has_main_screen() -> bool:
    return true


func make_visible(visible: bool) -> void:
    if is_instance_valid(_main_panel):
        _main_panel.visible = visible


func get_plugin_name() -> String:
    return _display_name


func get_plugin_icon() -> Texture:
    # TODO: We need better support for updating icon colors based on theme: 
    # https://github.com/godotengine/godot-proposals/issues/572
    var is_light_theme: bool = \
            get_editor_interface().get_editor_settings() \
                .get_setting("interface/theme/base_color").v > 0.5
    var theme := "light" if is_light_theme else "dark"
    var scale := get_editor_interface().get_editor_scale()
    var icon_path := _get_editor_icon_path(theme, scale)
    return load(icon_path) as Texture


func _validate_editor_icons() -> void:
    var file := File.new()
    for theme in ["light", "dark"]:
        for scale in [0.75, 1.0, 1.5, 2.0]:
            var path := _get_editor_icon_path(theme, scale)
            assert(file.file_exists(path),
                    "Plugin editor-icon version is missing: " +
                    "plugin=%s, theme=%s, scale=%s, path=%s" % [
                        _display_name,
                        theme,
                        str(scale),
                        path,
                    ])


func _get_editor_icon_path(
        theme: String,
        scale: float) -> String:
    return (_icon_directory_path + "editor_icon_%s_theme_%s.png") % [
        theme,
        str(scale),
    ]
