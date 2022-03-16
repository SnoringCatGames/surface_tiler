tool
class_name FrameworkManifestPanel
extends VBoxContainer


const _ROW_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/framework_manifest_row.tscn")
const _ARRAY_BUTTONS_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/framework_manifest_array_buttons.tscn")

const _PANEL_WIDTH := 1000.0
const _CONTROL_WIDTH := 320.0
const _PADDING := 4.0
const _INDENT_WIDTH := 20.0
const _LABEL_WIDTH := _PANEL_WIDTH - _CONTROL_WIDTH - _PADDING * 3.0

var _row_count := 0


func _init() -> void:
    self.rect_min_size.x = _PANEL_WIDTH
    
    _row_count = 0
    
    Sc.utils.clear_children(self)
    
    _create_property_controls_from_dictionary(
            St.manifest_controller.properties,
            "",
            self,
            0)


func _create_property_controls_from_dictionary(
        properties: Dictionary,
        parent_key: String,
        parent: Container,
        depth: int) -> void:
    # Create the Dictionary row / label.
    if depth > 0:
        _create_property_control_from_value(
                properties,
                TYPE_DICTIONARY,
                parent_key,
                properties,
                parent,
                depth)
    
    for key in properties:
        if key.begins_with(
                FrameworkManifestController._PROPERTY_TYPE_KEY_PREFIX):
            continue
        
        var value = properties[key]
        var type = properties[
                FrameworkManifestController._PROPERTY_TYPE_KEY_PREFIX + key]
        
        if value is Dictionary:
            _create_property_controls_from_dictionary(
                    value, key, parent, depth + 1)
        elif value is Array:
            assert(type.size() == 1)
            _create_property_controls_from_array(
                    value, type[0], key, parent, depth + 1)
        else:
            _create_property_control_from_value(
                    value, type, key, properties, parent, depth)


func _create_property_controls_from_array(
        properties: Array,
        type,
        parent_key: String,
        parent: Container,
        depth: int) -> void:
    # Create the Array row / label
    if depth > 0:
        _create_property_control_from_value(
                properties,
                TYPE_ARRAY,
                parent_key,
                properties,
                parent,
                depth)
    
    # FIXME: LEFT OFF HERE: ------------------
    # - Create editing/adding/removing/bulk buttons.
    
    for i in properties.size():
        var value = properties[i]
        var key: String = "[%d]" % i
        
        if type is Dictionary:
            _create_property_controls_from_dictionary(
                    value, key, parent, depth + 1)
        elif type is Array:
            assert(type.size() == 1)
            _create_property_controls_from_array(
                    value, type[0], key, parent, depth + 1)
        else:
            _create_property_control_from_value(
                    value, type, key, properties, parent, depth)
    
    _create_array_buttons(
            properties,
            type,
            parent,
            depth)


func _create_property_control_from_value(
        value,
        type: int,
        key,
        property_parent,
        control_parent: Container,
        depth: int) -> void:
    var row := Sc.utils.add_scene(self, _ROW_SCENE)
    
    row.value = value
    row.type = type
    row.key = key
    row.property_parent = property_parent
    row.depth = depth
    
    row.set_up(
            control_parent,
            _row_count,
            _LABEL_WIDTH,
            _CONTROL_WIDTH,
            _PADDING,
            _INDENT_WIDTH)
    row.connect("changed", self, "_on_value_changed")
    
    _row_count += 1


func _create_array_buttons(
        property_parent,
        type,
        control_parent: Container,
        depth: int) -> void:
    var buttons := Sc.utils.add_scene(self, _ARRAY_BUTTONS_SCENE)
    
    buttons.depth = depth
    
    buttons.set_up(
            control_parent,
            _LABEL_WIDTH,
            _CONTROL_WIDTH,
            _PADDING,
            _INDENT_WIDTH)
    buttons.connect(
            "added",
            self,
            "_on_array_item_added",
            [property_parent, type])
    buttons.connect(
            "deleted",
            self,
            "_on_array_item_deleted",
            [property_parent, type])
    
    _row_count += 1


func _on_value_changed() -> void:
    St.manifest_controller.save()


func _on_array_item_added(
        property_parent,
        type) -> void:
    # FIXME: LEFT OFF HERE: ------------------------------
    pass


func _on_array_item_deleted(
        property_parent,
        type) -> void:
    # FIXME: LEFT OFF HERE: ------------------------------
    pass
