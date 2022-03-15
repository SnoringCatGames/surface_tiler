tool
class_name SurfaceTilerMainPanel
extends CenterContainer


# FIXME: LEFT OFF HERE: -----------------


var controller: FrameworkManifestController


func set_up(controller: FrameworkManifestController) -> void:
    self.controller = controller
    $VBoxContainer/FrameworkManifestPanel.set_up(controller)
