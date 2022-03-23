tool
class_name RecalculateTilesetCustomProperty
extends FrameworkManifestCustomProperty


func set_up(
        node: FrameworkManifestEditorNode,
        row,
        parent_control: Control,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    self.row = row
    self.parent_control = parent_control
    
    var container := HBoxContainer.new()
    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.mouse_filter = Control.MOUSE_FILTER_PASS
    parent_control.add_child(container)
    
    var button := Button.new()
    button.text = "Recalculate"
    button.rect_min_size.x = control_width
    button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    button.connect(
            "pressed",
            self,
            "_on_button_pressed",
            [node.parent.children.tile_set.value])
    container.add_child(button)
    
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer.mouse_filter = Control.MOUSE_FILTER_PASS
    container.add_child(spacer)
    
    # Move this button's row to the top.
    var row_parent: Control = row.get_parent()
    row_parent.move_child(row, 0)


func _on_button_pressed(tile_set: CornerMatchTileset) -> void:
    St.initializer.initialize_tileset(tile_set._config, true)
