tool
class_name TilesetAnnotationsRecorder
extends Node


func load_corner_type_annotation_key(
        corner_type_annotation_key_path: String) -> Dictionary:
    var encoding_path := _get_json_path(corner_type_annotation_key_path)
    return Sc.json.load_file(
            encoding_path,
            false,
            true)


func save_corner_type_annotation_key(
        corner_type_annotation_key_path: String,
        key: Dictionary) -> void:
    var encoding_path := _get_json_path(corner_type_annotation_key_path)
    Sc.json.save_file(
            key,
            encoding_path,
            false,
            false)


func load_tileset_corner_type_annotations(
        tileset_corner_type_annotations_path: String) -> Dictionary:
    var encoding_path := _get_json_path(tileset_corner_type_annotations_path)
    var encoding := Sc.json.load_file(
            encoding_path,
            false,
            true)
    return decode_tileset_corner_type_annotations(encoding)


func save_tileset_corner_type_annotations(
        tileset_corner_type_annotations_path: String,
        annotations: Dictionary) -> void:
    var encoding_path := _get_json_path(tileset_corner_type_annotations_path)
    var encoding: Dictionary = \
            encode_tileset_corner_type_annotations(annotations)
    Sc.json.save_file(
            encoding,
            encoding_path,
            false,
            false)


func decode_tileset_corner_type_annotations(encoding):
    if encoding is Dictionary:
        var value := {}
        for key in encoding:
            value[int(key)] = \
                    decode_tileset_corner_type_annotations(encoding[key])
        return value
    else:
        return Sc.json.decode_vector2(encoding)


func encode_tileset_corner_type_annotations(value):
    if value is Dictionary:
        var encoding := {}
        for key in value:
            encoding[key] = encode_tileset_corner_type_annotations(value[key])
        return encoding
    else:
        return Sc.json.encode_vector2(value)


func _get_json_path(image_path: String) -> String:
    assert(image_path.ends_with(".png"))
    return image_path.trim_suffix(".png") + ".json"