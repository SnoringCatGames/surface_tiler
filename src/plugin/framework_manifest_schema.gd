tool
class_name FrameworkManifestSchema
extends Reference


const TYPE_SCRIPT := 1001
const TYPE_TILESET := 1002

const _DEFAULT_VALUES := {
    TYPE_BOOL: false,
    TYPE_STRING: "",
    TYPE_INT: -1,
    TYPE_REAL: INF,
    TYPE_COLOR: Color.black,
    TYPE_ARRAY: [],
    TYPE_DICTIONARY: {},
    TYPE_SCRIPT: null,
    TYPE_TILESET: null,
}


func get_framework_display_name() -> String:
    Sc.logger.error(
            "Abstract FrameworkManifestSchema.get_framework_display_name " +
            "is not implemented")
    return ""


func get_framework_folder_name() -> String:
    Sc.logger.error(
            "Abstract FrameworkManifestSchema.get_framework_folder_name " +
            "is not implemented")
    return ""


func get_properties() -> Dictionary:
    Sc.logger.error(
            "Abstract FrameworkManifestSchema.get_properties " +
            "is not implemented")
    return {}


static func get_allowed_manifest_schema_types_set() -> Dictionary:
    var set := {}
    for type in _DEFAULT_VALUES:
        set[type] = true
    return set


static func get_default_value(type):
    if !(type is int):
        return type
    return _DEFAULT_VALUES[type]
