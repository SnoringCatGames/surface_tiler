tool
class_name RecalculateTilesetCustomProperty
extends FrameworkManifestCustomProperty


# FIXME: LEFT OFF HERE: -------------------


func get_ui() -> Control:
    var container := HBoxContainer.new()
    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var button := Button.new()
    button.text = "Recalculate"
    button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    button.connect("pressed", self, "_on_button_pressed")
    container.add_child(button)
    
    return container


func _on_button_pressed() -> void:
    St.initializer.initialize_tileset(property_parent.tile_set._config)
