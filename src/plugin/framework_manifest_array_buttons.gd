tool
class_name FrameworkManifestArrayButtons
extends PanelContainer


signal added
signal deleted

var depth: int


func set_up(
        control_parent: Container,
        label_width: float,
        control_width: float,
        padding: float,
        indent_width: float) -> void:
    $MarginContainer.add_constant_override("margin_top", padding)
    $MarginContainer.add_constant_override("margin_bottom", padding)
    $MarginContainer.add_constant_override("margin_left", padding)
    $MarginContainer.add_constant_override("margin_right", padding)
    
    $MarginContainer/HBoxContainer.add_constant_override("separation", padding)
    
    if depth > 0:
        $MarginContainer/HBoxContainer/Indent.rect_min_size.x = \
                indent_width * depth - padding
    else:
        $MarginContainer/HBoxContainer/Indent.queue_free()


func _on_DeleteButton_pressed():
    emit_signal("deleted")


func _on_AddButton_pressed():
    emit_signal("added")
