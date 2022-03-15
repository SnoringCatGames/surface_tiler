tool
class_name FrameworkManifestPanel
extends VBoxContainer


# FIXME: LEFT OFF HERE: ------------------------------------
# - controller.save()


var controller: FrameworkManifestController


func set_up(controller: FrameworkManifestController) -> void:
    self.controller = controller
    _create_property_controls_from_dictionary(controller.properties)


func _create_property_controls_from_dictionary(
        properties: Dictionary,
        key := "") -> void:
    # FIXME: LEFT OFF HERE: ------------------
    # - Create the Dictionary row / label.
    for key in properties:
        var value = properties[key]
        if value is Dictionary:
            _create_property_controls_from_dictionary(value, key)
        elif value is Array:
            _create_property_controls_from_array(value, key)
        else:
            _create_property_control_from_value(value, key)


func _create_property_controls_from_array(
        properties: Array,
        key: String) -> void:
    # FIXME: LEFT OFF HERE: ------------------
    # - Create the Array row / label / any needed editing/adding/removing/bulk buttons.
    for i in properties.size():
        var value = properties[i]
        # FIXME: LEFT OFF HERE: ------------------
        pass


func _create_property_control_from_value(
        value,
        key: String) -> void:
    # FIXME: LEFT OFF HERE: ------------------
    pass
