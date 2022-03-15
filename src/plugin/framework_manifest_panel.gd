tool
class_name FrameworkManifestPanel
extends VBoxContainer


const _ROW_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/framework_manifest_row.tscn")

const _PANEL_WIDTH := 1000.0
const _CONTROL_WIDTH := 320.0
const _PADDING := 4.0
const _LABEL_WIDTH := _PANEL_WIDTH - _CONTROL_WIDTH - _PADDING * 3.0

var _row_count := 0


func _init() -> void:
    self.rect_min_size.x = _PANEL_WIDTH
    
    _row_count = 0
    
    Sc.utils.clear_children(self)
    
    _create_property_controls_from_dictionary(
            St.manifest_controller.properties,
            "",
            self)


func _create_property_controls_from_dictionary(
        properties: Dictionary,
        key: String,
        parent: Container) -> void:
    # FIXME: LEFT OFF HERE: ------------------
    # - Create the Dictionary row / label.
    for key in properties:
        if key.begins_with(
                FrameworkManifestController._PROPERTY_TYPE_KEY_PREFIX):
            continue
        
        var value = properties[key]
        var type = properties[
                FrameworkManifestController._PROPERTY_TYPE_KEY_PREFIX + key]
        
        if value is Dictionary:
            _create_property_controls_from_dictionary(
                    value, key, parent)
        elif value is Array:
            _create_property_controls_from_array(
                    value, key, parent)
        else:
            _create_property_control_from_value(
                    value, type, key, properties, parent)


func _create_property_controls_from_array(
        properties: Array,
        key: String,
        parent: Container) -> void:
    # FIXME: LEFT OFF HERE: ------------------
    # - Create the Array row / label / any needed editing/adding/removing/bulk buttons.
    for i in properties.size():
        var value = properties[i]
        # FIXME: LEFT OFF HERE: ------------------
        pass


func _create_property_control_from_value(
        value,
        type: int,
        key,
        property_parent,
        control_parent: Container) -> void:
    var row := Sc.utils.add_scene(self, _ROW_SCENE)
    
    row.value = value
    row.type = type
    row.key = key
    row.property_parent = property_parent
    
    row.set_up(
        control_parent,
        _row_count,
        _LABEL_WIDTH,
        _CONTROL_WIDTH,
        _PADDING)
    row.connect("changed", self, "_on_value_changed")
    
    _row_count += 1


func _on_value_changed() -> void:
    St.manifest_controller.save()
