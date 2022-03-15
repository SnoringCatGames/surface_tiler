tool
class_name FrameworkManifestPanel
extends VBoxContainer


# FIXME: LEFT OFF HERE: ------------------------------------
# - controller.save()


var controller: FrameworkManifestController


func set_up(controller: FrameworkManifestController) -> void:
    self.controller = controller
    _create_property_controls_from_dictionary(
            controller.properties,
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
    var hbox := HBoxContainer.new()
    control_parent.add_child(hbox)
    
    var label := Label.new()
    label.text = key.capitalize()
    hbox.add_child(label)
    
    var control: Control
    match type:
        TYPE_BOOL:
            control = _create_bool_editor(value, key, property_parent)
        TYPE_INT:
            control = _create_int_editor(value, key, property_parent)
        TYPE_REAL:
            control = _create_float_editor(value, key, property_parent)
        TYPE_STRING:
            control = _create_string_editor(value, key, property_parent)
        TYPE_COLOR:
            control = _create_color_editor(value, key, property_parent)
        FrameworkManifestSchema.TYPE_SCRIPT, \
        FrameworkManifestSchema.TYPE_TILESET, \
        FrameworkManifestSchema.TYPE_RESOURCE:
            control = _create_resource_editor(
                    value,
                    key,
                    property_parent,
                    type)
        _:
            Sc.logger.error(
                    "FrameworkManifestPanel._create_property_control_from_value")
    hbox.add_child(control)


func _create_bool_editor(
        value: bool,
        key,
        property_parent) -> CheckBox:
    var control := CheckBox.new()
    control.pressed = true
    control.connect(
            "toggled",
            self,
            "_on_bool_changed",
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
            "_on_int_changed",
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
            "_on_float_changed",
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
        property_parent) -> ColorPicker:
    var control := ColorPicker.new()
    control.color = value
    control.connect(
            "color_changed",
            self,
            "_on_color_changed",
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
            "_on_resource_changed",
            [key, property_parent])
    return control


func _on_bool_changed(
        value: bool,
        key,
        property_parent) -> void:
    property_parent[key] = value


func _on_int_changed(
        value: float,
        key,
        property_parent) -> void:
    property_parent[key] = int(value)


func _on_float_changed(
        value: float,
        key,
        property_parent) -> void:
    property_parent[key] = value


func _on_string_changed(
        control: TextEdit,
        key,
        property_parent) -> void:
    property_parent[key] = control.text


func _on_color_changed(
        value: Color,
        key,
        property_parent) -> void:
    property_parent[key] = value


func _on_resource_changed(
        value: Resource,
        key,
        property_parent) -> void:
    property_parent[key] = value
