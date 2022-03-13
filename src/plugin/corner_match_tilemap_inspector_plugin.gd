tool
class_name CornerMatchTilemapInspectorPlugin
extends EditorInspectorPlugin


func can_handle(object: Object) -> bool:
    return object is CornerMatchTilemap


func parse_begin(object: Object) -> void:
    var recalculate_cells_button := Button.new()
    recalculate_cells_button.text = "Recalculate cells"
    recalculate_cells_button.connect(
            "pressed",
            self,
            "_on_recalculate_cells_pressed",
            [object])
    add_custom_control(recalculate_cells_button)
    
    var reset_manual_cells_button := Button.new()
    reset_manual_cells_button.text = "Reset manual-override cells"
    reset_manual_cells_button.connect(
            "pressed",
            self,
            "_on_reset_manual_cells_pressed",
            [object])
    add_custom_control(reset_manual_cells_button)


func _on_recalculate_cells_pressed(tilemap: CornerMatchTilemap) -> void:
    tilemap.recalculate_cells()


func _on_reset_manual_cells_pressed(tilemap: CornerMatchTilemap) -> void:
    tilemap.reset_manual_cells()
