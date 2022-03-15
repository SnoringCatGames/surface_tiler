tool
class_name SurfaceTilerMainPanel
extends CenterContainer


func _init() -> void:
    $VBoxContainer/Label.text = \
            St.manifest_controller.schema.get_framework_display_name()
