tool
extends EditorPlugin


var corner_match_tilemap_inspector_plugin: CornerMatchTilemapInspectorPlugin


func _enter_tree():
    var corner_match_tilemap_inspector_plugin := \
            CornerMatchTilemapInspectorPlugin.new()
    add_inspector_plugin(corner_match_tilemap_inspector_plugin)


func _exit_tree():
    remove_inspector_plugin(corner_match_tilemap_inspector_plugin)
