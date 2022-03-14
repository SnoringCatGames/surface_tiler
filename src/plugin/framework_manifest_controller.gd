tool
class_name FrameworkManifestController
extends Reference


var _SECTION := "manifest"
var _KEY := "properties"

var schema: FrameworkManifestSchema

var properties: Dictionary

var config_file := ConfigFile.new()


func set_up(schema: FrameworkManifestSchema) -> void:
    self.schema = schema
    
    # FIXME: LEFT OFF HERE: --------------------
    var display_name := schema.get_framework_display_name()
    
    _validate_schema()
    _load_property_values()
    _save_property_values()
    _create_property_controls()


func _validate_schema() -> void:
    var schema_properties := schema.get_properties()
    var valid_schema_types := \
            FrameworkManifestSchema.get_allowed_manifest_schema_types_set()
    _validate_schema_recursively(schema_properties, valid_schema_types)


func _validate_schema_recursively(
        schema_properties: Dictionary,
        valid_schema_types: Dictionary,
        prefix := "") -> void:
    for key in schema_properties:
        var value = schema_properties[key]
        assert(value is Dictionary or \
                value is Array or \
                value is int and valid_schema_types.has(value),
                "Invalid manifest schema type: %s" % prefix + key)
        if value is Dictionary:
            _validate_schema_recursively(
                    value,
                    valid_schema_types,
                    prefix + key + ">")
        elif value is Array:
            assert(value.size() == 1,
                "Manifest schema arrays must be of size 1: %s" % prefix + key)
            _validate_schema_recursively(
                    value[0],
                    valid_schema_types,
                    prefix + key + ">")


func _load_property_values() -> void:
    var status := config_file.load(get_settings_path())
    if status != OK and \
            status != ERR_FILE_NOT_FOUND:
        Sc.logger.error("Unable to load manifest file (%s): %s" % [
            get_settings_path(),
            str(status),
        ])
        return
    
    properties = config_file.get_value(_SECTION, _KEY, {})
    assert(properties is Dictionary)
    
    _clean_property_values()


func _save_property_values() -> void:
    var status := config_file.save(get_settings_path())
    if status != OK:
        Sc.logger.error("Unable to save manifest file (%s): %s" % [
            get_settings_path(),
            str(status),
        ])


func _clean_property_values() -> void:
    var schema_properties := schema.get_properties()
    _clean_dictionary_values(
            properties,
            schema_properties)


func _clean_dictionary_values(
        local_properties: Dictionary,
        schema_properties: Dictionary,
        config_key_prefix := "") -> void:
    # Remove any invalid keys from the dictionary.
    for key in local_properties.keys():
        if !schema_properties.has(key):
            local_properties.erase(key)
    
    for key in schema_properties:
        var type = schema_properties[key]
        
        # Ensure an entry exists for this key.
        if !local_properties.has(key):
            local_properties[key] = \
                    FrameworkManifestSchema.get_default_value(type)
        var saved_value = local_properties[key]
        
        # Ensure this value is the correct type.
        if !_get_is_expected_type(saved_value, type):
            Sc.logger.warning(
                    ("Invalid value saved in manifest: " +
                    "%s => %s (expected type %s)") % [
                        config_key_prefix + key,
                        str(saved_value),
                        str(type),
                    ])
            local_properties[key] = \
                    FrameworkManifestSchema.get_default_value(type)
            saved_value = local_properties[key]
        
        if type is Dictionary:
            _clean_dictionary_values(
                    saved_value,
                    type,
                    config_key_prefix + key + ">")
        elif type is Array:
            if type.size() == 1:
                _clean_array_values(
                        saved_value,
                        type[0],
                        config_key_prefix + key + ">")
            else:
                # Do nothing.
                # The schema doesn't specify any structure for this array.
                pass


func _clean_array_values(
        local_properties: Array,
        schema_type,
        config_key_prefix := "") -> void:
    # Remove any invalid-typed entries from the array.
    for i in local_properties.size():
        if !_get_is_expected_type(local_properties[i], schema_type):
            local_properties.remove(i)
            i -= 1
    
    if schema_type is Dictionary:
        for i in local_properties.size():
            _clean_dictionary_values(
                    local_properties[i],
                    schema_type,
                    config_key_prefix + "[%d]>" % i)
    elif schema_type is Array:
        if schema_type.size() == 1:
            for i in local_properties.size():
                _clean_array_values(
                        local_properties[i],
                        schema_type[0],
                        config_key_prefix + "[%d]>" % i)
        else:
            # Do nothing.
            # The schema doesn't specify any structure for this array.
            pass


func _get_is_expected_type(value, type) -> bool:
    return type is int and typeof(value) == type or \
            type is Dictionary and value is Dictionary or \
            type is Array and value is Array


func get_settings_path() -> String:
    var folder_name := schema.get_framework_folder_name()
    return "res://addons/%s/manifest.cfg" % folder_name


func _create_property_controls() -> void:
    var schema_properties := schema.get_properties()
    for key in schema_properties:
        # FIXME: LEFT OFF HERE: -----------------
        pass
