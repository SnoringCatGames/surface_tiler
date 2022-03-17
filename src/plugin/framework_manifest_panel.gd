tool
class_name FrameworkManifestPanel
extends ScrollContainer


const _ROW_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/framework_manifest_row.tscn")
const _ROW_GROUP_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/framework_manifest_row_group.tscn")
const _ARRAY_BUTTONS_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/framework_manifest_array_buttons.tscn")

const _PANEL_WIDTH := 600.0
const _CONTROL_WIDTH := 320.0
const _PADDING := 4.0
const _LABEL_WIDTH := _PANEL_WIDTH - _CONTROL_WIDTH - _PADDING * 3.0


func _ready() -> void:
    $VBoxContainer.rect_min_size.x = _PANEL_WIDTH
    
    Sc.utils.clear_children($VBoxContainer)
    
    _create_property_controls_from_dictionary(
            St.manifest_controller.properties,
            "",
            $VBoxContainer)
    
    _update_zebra_stripes()


func _create_property_controls_from_dictionary(
        properties: Dictionary,
        parent_key,
        parent: Container) -> FrameworkManifestRowGroup:
    # Create the Dictionary row / label.
    var row: FrameworkManifestRowGroup
    var is_root: bool = \
            parent_key is String and \
            parent_key == ""
    if !is_root:
        row = _create_group_control(
                properties,
                properties,
                parent_key,
                properties,
                parent)
        parent = row.body
    
    for key in properties:
        if key.begins_with(FrameworkManifestSchema._PROPERTY_TYPE_KEY_PREFIX):
            continue
        elif key.begins_with(FrameworkManifestSchema._CUSTOM_TYPE_KEY_PREFIX):
            _create_row_for_custom_type(
                    properties,
                    key,
                    parent)
        else:
            _create_row_for_dictionary_item(
                    properties,
                    key,
                    parent)
    
    return row


func _create_row_for_custom_type(
        properties: Dictionary,
        key: String,
        parent: Container) -> void:
    var custom_property: FrameworkManifestCustomProperty = properties[key].new()
    custom_property.key = key
    custom_property.property_parent = properties
    var ui := custom_property.get_ui()
    parent.add_child(ui)


func _create_row_for_dictionary_item(
        properties: Dictionary,
        key: String,
        parent: Container) -> void:
    var value = properties[key]
    var type = properties[
            FrameworkManifestSchema._PROPERTY_TYPE_KEY_PREFIX + key]
    if value is Dictionary:
        _create_property_controls_from_dictionary(
                value, key, parent)
    elif value is Array:
        _create_property_controls_from_array(
                value, type, key, parent)
    else:
        _create_property_control_from_value(
                value, type, key, properties, parent)


func _create_property_controls_from_array(
        properties: Array,
        type,
        parent_key,
        parent: Container) -> FrameworkManifestRowGroup:
    # Create the Array row / label
    var row: FrameworkManifestRowGroup
    var is_root: bool = \
            parent_key is String and \
            parent_key == ""
    if !is_root:
        row = _create_group_control(
                properties,
                type,
                parent_key,
                properties,
                parent)
        parent = row.body
    assert(type.size() == 1)
    type = type[0]
    
    for i in properties.size():
        _create_row_for_array_item(
                properties,
                i,
                type,
                parent)
    
    return row


func _create_row_for_array_item(
        properties: Array,
        i: int,
        type,
        parent: Container) -> void:
    var value = properties[i]
    var row
    if type is Dictionary:
        row = _create_property_controls_from_dictionary(
                value, i, parent)
    elif type is Array:
        row = _create_property_controls_from_array(
                value, type, i, parent)
    else:
        row = _create_property_control_from_value(
                value, type, i, properties, parent)


func _create_property_control_from_value(
        value,
        type: int,
        key,
        property_parent,
        control_parent: Container) -> FrameworkManifestRow:
    var row: FrameworkManifestRow = \
            Sc.utils.add_scene(control_parent, _ROW_SCENE)
    
    row.value = value
    row.type = type
    row.key = key
    row.property_parent = property_parent
    
    row.set_up(
            _LABEL_WIDTH,
            _CONTROL_WIDTH,
            _PADDING)
    row.connect("changed", self, "_on_value_changed")
    
    return row


func _create_group_control(
        value,
        type,
        key,
        property_parent,
        control_parent: Container) -> FrameworkManifestRowGroup:
    var row: FrameworkManifestRowGroup = \
            Sc.utils.add_scene(control_parent, _ROW_GROUP_SCENE)
    
    row.value = value
    row.type = type
    row.key = key
    row.property_parent = property_parent
    
    row.set_up(
            _LABEL_WIDTH,
            _CONTROL_WIDTH,
            _PADDING)
    
    if property_parent is Array:
        row.buttons.connect(
                "added",
                self,
                "_on_array_item_added",
                [row.buttons])
        row.buttons.connect(
                "deleted",
                self,
                "_on_array_item_deleted",
                [row.buttons])
    
    return row


func _on_value_changed() -> void:
    St.manifest_controller.save()


func _on_array_item_added(buttons: FrameworkManifestArrayButtons) -> void:
    var body: Container = buttons.group.body
    var i := body.get_child_count()
    var type = buttons.type[0]
    
    # Create the data field.
    St.manifest_controller._clean_array_element(
            i,
            type,
            buttons.property_parent)
    
    # Create the UI.
    _create_row_for_array_item(
            buttons.property_parent,
            i,
            type,
            body)
    
    _update_zebra_stripes()
    _on_value_changed()


func _on_array_item_deleted(buttons: FrameworkManifestArrayButtons) -> void:
    buttons.property_parent.pop_back()
    buttons.group.body.get_children().back().queue_free()
    _update_zebra_stripes()
    _on_value_changed()


func _update_zebra_stripes() -> void:
    var row_count := 0
    for row in $VBoxContainer.get_children():
        if is_instance_valid(row):
            row_count = row.update_zebra_stripes(row_count)


func update_size(size: Vector2) -> void:
    self.rect_min_size.x = size.x - 144.0
    self.rect_min_size.y = size.y - 144.0
