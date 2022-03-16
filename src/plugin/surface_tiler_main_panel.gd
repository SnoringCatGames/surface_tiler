tool
class_name SurfaceTilerMainPanel
extends CenterContainer


var _throttled_on_resize: FuncRef = Sc.time.throttle(
        funcref(self, "_adjust_size"),
        0.04,
        false,
        TimeType.APP_PHYSICS)


func _ready() -> void:
    $VBoxContainer/Label.text = \
            St.manifest_controller.schema.get_framework_display_name()
    _adjust_size()
    connect("resized", _throttled_on_resize, "call_func")


func _adjust_size() -> void:
    var size: Vector2 = get_parent().rect_size
    size.y -= $VBoxContainer/Label.rect_size.y
    size.y -= $VBoxContainer/Spacer.rect_size.y
    $VBoxContainer/CenterContainer/FrameworkManifestPanel.update_size(size)
