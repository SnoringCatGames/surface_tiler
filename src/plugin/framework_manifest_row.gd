tool
class_name FrameworkManifestRow
extends PanelContainer


signal changed

var value
var type: int
var key
var property_parent


func set_up(
        control_parent: Container,
        index: int,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    var style: StyleBox
    if index % 2 == 0:
        style = StyleBoxEmpty.new()
    else:
        style = StyleBoxFlat.new()
        style.bg_color = Color.from_hsv(0.0, 0.0, 0.7, 0.1)
    
    self.add_stylebox_override("panel", style)
    
    $MarginContainer.add_constant_override("margin_top", padding)
    $MarginContainer.add_constant_override("margin_bottom", padding)
    $MarginContainer.add_constant_override("margin_left", padding)
    $MarginContainer.add_constant_override("margin_right", padding)
    
    $MarginContainer/HBoxContainer.add_constant_override("separation", padding)
    
    $MarginContainer/HBoxContainer/Label.text = key.capitalize()
    $MarginContainer/HBoxContainer/Label.rect_min_size.x = label_width
    $MarginContainer/HBoxContainer/Label.rect_size.x = label_width
    
    var value_editor := _create_value_editor()
    value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
    value_editor.rect_clip_content = true
    value_editor.rect_min_size.x = control_width
    value_editor.rect_size.x = control_width
    $MarginContainer/HBoxContainer.add_child(value_editor)


func _create_value_editor() -> Control:
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
    control.pressed = true
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
