tool
class_name SurfaceTilerMainPanel
extends CenterContainer


func _ready() -> void:
    $VBoxContainer/Label.text = \
            St.manifest_controller.schema.get_framework_display_name()
