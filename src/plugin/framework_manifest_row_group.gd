tool
class_name FrameworkManifestRowGroup
extends VBoxContainer


var header: FrameworkManifestRow
var body: Container
var buttons: FrameworkManifestArrayButtons

var value
var type
var key
var property_parent


func set_up(
        label_width: float,
        control_width: float,
        padding: float) -> void:
    header = $HBoxContainer2/Header
    body = $HBoxContainer/Body
    buttons = $HBoxContainer2/Buttons
    
    header.value = value
    header.type = type
    header.key = key
    header.property_parent = property_parent
    
    header.set_up(
        label_width,
        control_width,
        padding)
    
    if property_parent is Array:
        buttons.group = self
        buttons.type = type
        buttons.property_parent = property_parent
        buttons.set_up(
                label_width,
                control_width,
                padding)
    else:
        buttons.queue_free()


func update_zebra_stripes(index: int) -> int:
    if is_instance_valid(header):
        header.update_zebra_stripes(index)
    if is_instance_valid(buttons):
        buttons.update_zebra_stripes(index)
    
    index += 1
    
    for row in body.get_children():
        if is_instance_valid(row):
            index = row.update_zebra_stripes(index)
    
    return index
