tool
class_name CornerMatchTileset
extends TileSet


var _config: Dictionary

# Dictionary<int, CornerMatchTile>
var ids_to_corner_match_tiles := {}

var is_initialized := false

var subtile_size := Vector2.INF


func _is_tile_bound(
        drawn_id: int,
        neighbor_id: int) -> bool:
    # FIXME: LEFT OFF HERE: -------------- How's this supposed to work in v3.5?
    return false
