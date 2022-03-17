tool
class_name FrameworkManifestSchema
extends Reference


const TYPE_SCRIPT := 1001
const TYPE_TILESET := 1002
const TYPE_RESOURCE := 1003

const _DEFAULT_VALUES := {
    TYPE_BOOL: false,
    TYPE_STRING: "",
    TYPE_INT: -1,
    TYPE_REAL: INF,
    TYPE_COLOR: Color.black,
    TYPE_SCRIPT: null,
    TYPE_TILESET: null,
    TYPE_RESOURCE: null,
}

const _PROPERTY_TYPE_KEY_PREFIX := "$type:"
const _CUSTOM_TYPE_KEY_PREFIX := "$custom:"


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


func get_manifest_path() -> String:
    var folder_name := get_framework_folder_name()
    return "res://addons/%s/manifest.json" % folder_name


static func get_allowed_manifest_schema_types_set() -> Dictionary:
    var set := {}
    for type in _DEFAULT_VALUES:
        set[type] = true
    return set


static func get_default_value(type):
    if type is Dictionary:
        return {}
    elif type is Array:
        return []
    elif type is Script:
        return type
    else:
        return _DEFAULT_VALUES[type]


static func get_is_expected_type(
        value,
        expected_type) -> bool:
    if expected_type is int:
        var actual_type := get_type(value)
        match expected_type:
            actual_type:
                return true
            TYPE_SCRIPT, \
            TYPE_TILESET, \
            TYPE_RESOURCE:
                return value == null
            TYPE_INT, \
            TYPE_REAL:
                return actual_type == TYPE_INT or actual_type == TYPE_REAL
            _:
                return false
    elif expected_type is Dictionary:
        return value is Dictionary
    elif expected_type is Array:
        return value is Array
    elif expected_type is Script:
        return value is Script or value == null
    else:
        return false


static func get_type(value) -> int:
    if value is Script:
        return TYPE_SCRIPT
    elif value is TileSet:
        return TYPE_TILESET
    elif value is Resource:
        return TYPE_RESOURCE
    else:
        return typeof(value)


static func get_type_string(type) -> String:
    if type is int:
        pass
    elif type is Dictionary:
        type = TYPE_DICTIONARY
    elif type is Array:
        type = TYPE_ARRAY
    elif type is Script:
        return "TYPE_CUSTOM"
    else:
        Sc.logger.error("FrameworkManifestSchema.get_type_string")
        return ""
    
    match type:
        TYPE_SCRIPT:
            return "TYPE_SCRIPT"
        TYPE_TILESET:
            return "TYPE_TILESET"
        TYPE_RESOURCE:
            return "TYPE_RESOURCE"
        _:
            return Sc.utils.get_type_string(type)


static func get_resource_class_name(type: int) -> String:
    match type:
        TYPE_SCRIPT:
            return "Script"
        TYPE_TILESET:
            return "TileSet"
        TYPE_RESOURCE:
            return "Resource"
        _:
            Sc.logger.error("FrameworkManifestSchema.get_resource_class_name")
            return ""
