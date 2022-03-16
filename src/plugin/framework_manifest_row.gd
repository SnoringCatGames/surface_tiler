tool
class_name FrameworkManifestRow
extends PanelContainer


signal changed

var value
var type
var key
var property_parent


func set_up(
        label_width: float,
        control_width: float,
        padding: float) -> void:
    $MarginContainer.add_constant_override("margin_top", padding)
    $MarginContainer.add_constant_override("margin_bottom", padding)
    $MarginContainer.add_constant_override("margin_left", padding)
    $MarginContainer.add_constant_override("margin_right", padding)
    
    $MarginContainer/HBoxContainer.add_constant_override("separation", padding)
    
    var text: String
    if key is int:
        text = "[%d]" % key
    else:
        text = key.capitalize()
    
    $MarginContainer/HBoxContainer/Label.text = text
    
    var value_editor := _create_value_editor()
    value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
    value_editor.rect_clip_content = true
    value_editor.rect_min_size.x = control_width
    $MarginContainer/HBoxContainer.add_child(value_editor)


func update_zebra_stripes(index: int) -> int:
    var style: StyleBox
    if index % 2 == 0:
        style = StyleBoxEmpty.new()
    else:
        style = StyleBoxFlat.new()
        style.bg_color = Color.from_hsv(0.0, 0.0, 0.7, 0.1)
    self.add_stylebox_override("panel", style)
    
    return index + 1


func _create_value_editor() -> Control:
    if type is Dictionary or \
            type is Array:
        # Use an empty placeholder control.
        return Control.new()
    
    match type:
        TYPE_BOOL:
            return _create_bool_editor(value, key, property_parent)
        TYPE_INT:
            return _create_int_editor(value, key, property_parent)
        TYPE_REAL:
            return _create_float_editor(value, key, property_parent)
        TYPE_STRING:
            return _create_string_editor(value, key, property_parent)
        TYPE_COLOR:
            return _create_color_editor(value, key, property_parent)
        FrameworkManifestSchema.TYPE_SCRIPT, \
        FrameworkManifestSchema.TYPE_TILESET, \
        FrameworkManifestSchema.TYPE_RESOURCE:
            return _create_resource_editor(
                    value,
                    key,
                    property_parent,
                    type)
        _:
            Sc.logger.error(
                    "FrameworkManifestPanel._create_property_control_from_value")
            return null


func _create_bool_editor(
        value: bool,
        key,
        property_parent) -> CheckBox:
    var control := CheckBox.new()
    control.pressed = value
    control.connect(
            "toggled",
            self,
            "_on_value_changed",
            [key, property_parent])
    return control


func _create_int_editor(
        value: int,
        key,
        property_parent) -> SpinBox:
    var control := SpinBox.new()
    control.step = 1.0
    control.rounded = true
    control.value = value
    control.connect(
            "value_changed",
            self,
            "_on_value_changed",
            [key, property_parent])
    return control


func _create_float_editor(
        value: float,
        key,
        property_parent) -> SpinBox:
    var control := SpinBox.new()
    control.step = 0.0
    control.rounded = false
    control.value = value
    control.connect(
            "value_changed",
            self,
            "_on_value_changed",
            [key, property_parent])
    return control


func _create_string_editor(
        value: String,
        key,
        property_parent) -> TextEdit:
    var control := TextEdit.new()
    control.text = value
    control.connect(
            "text_changed",
            self,
            "_on_string_changed",
            [control, key, property_parent])
    return control


func _create_color_editor(
        value: Color,
        key,
        property_parent) -> ColorPickerButton:
    var control := ColorPickerButton.new()
    control.color = value
    control.connect(
            "color_changed",
            self,
            "_on_value_changed",
            [key, property_parent])
    return control


func _create_resource_editor(
        value: Resource,
        key,
        property_parent,
        resource_type := -1) -> EditorResourcePicker:
    var control := EditorResourcePicker.new()
    control.edited_resource = value
    control.base_type = \
            FrameworkManifestSchema.get_resource_class_name(resource_type)
    control.connect(
            "resource_changed",
            self,
            "_on_value_changed",
            [key, property_parent])
    return control


func _on_value_changed(
        value,
        key,
        property_parent) -> void:
    property_parent[key] = value
    emit_signal("changed")


func _on_string_changed(
        control: TextEdit,
        key,
        property_parent) -> void:
    property_parent[key] = control.text
    emit_signal("changed")
