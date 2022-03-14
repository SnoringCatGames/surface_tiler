tool
class_name CornerConnectionWeightMultipliers
extends Reference
## -   This is needed for breaking ties when two quadrants have different
##     connections with equal weight.
## -   This depends on aspects of the tile_set's art.
##     -   For example, floor art might extend far enough to impact the lower
##         neighbor art, but wall and ceiling art might not.
## -   If you know that your tile_set has certain properties, like above, then
##     you might know that you can essentially ignore, or at least deprioritize,
##     some quadrant connections.
## -   Otherwise, you might need to change many quadrant connection annotations
##     from the original starting template, and also add many additional subtile
##     combinations to account for various adjacent corner-types.


const MULTIPLIERS := {
    SubtileCorner.EXT_90H: {
        top = 1.0,
        side = 1.0,
        bottom = 0.4,
        diagonal = 1.0,
    },
    SubtileCorner.EXT_90V: {
        top = 1.0,
        side = 0.4,
        bottom = 1.0,
        diagonal = 1.0,
    },
    SubtileCorner.EXT_45_H_SIDE: 0.9,
}


static func get_multiplier(
        corner_type: int,
        side_label: String) -> float:
    var multiplier: float
    if side_label == "":
        multiplier = 1.0
    elif MULTIPLIERS.has(corner_type):
        if MULTIPLIERS[corner_type] is Dictionary:
            multiplier = MULTIPLIERS[corner_type][side_label]
        else:
            multiplier = MULTIPLIERS[corner_type]
    else:
        multiplier = 1.0
    return 1.0 - (1.0 - multiplier) / 10000.0
