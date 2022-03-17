tool
class_name FrameworkManifestController
extends Reference


var schema: FrameworkManifestSchema

var properties: Dictionary


func set_up(schema: FrameworkManifestSchema) -> void:
    self.schema = schema
    
    _validate_schema()
    _load()
    save()


func _validate_schema() -> void:
    var schema_properties := schema.get_properties()
    var valid_schema_types := \
            FrameworkManifestSchema.get_allowed_manifest_schema_types_set()
    _validate_schema_recursively(schema_properties, valid_schema_types)


func _validate_schema_recursively(
        schema_value,
        valid_schema_types: Dictionary,
        prefix := "") -> void:
    assert(schema_value is Dictionary or \
            schema_value is Array or \
            schema_value is int and valid_schema_types.has(schema_value),
            "Invalid manifest schema type: %s" % prefix)
    
    if schema_value is Dictionary:
        for key in schema_value:
            var value = schema_value[key]
            if key.begins_with(FrameworkManifestSchema._CUSTOM_TYPE_KEY_PREFIX):
                assert(value is Script and \
                        value.get_base_script() == \
                            FrameworkManifestCustomProperty)
            else:
                _validate_schema_recursively(
                        value,
                        valid_schema_types,
                        prefix + key + ">")
    elif schema_value is Array:
        assert(schema_value.size() == 1,
                "Manifest schema arrays must be of size 1: %s" % prefix)
        _validate_schema_recursively(
                schema_value[0],
                valid_schema_types,
                prefix + "[0]>")


func _load() -> void:
    properties = Sc.json.load_file(schema.get_manifest_path(), true, true)
    _clean_property_values()


func save() -> void:
    Sc.json.save_file(
            _filter_out_meta_keys(properties),
            schema.get_manifest_path(),
            true,
            true)


func _filter_out_meta_keys(value):
    if value is Dictionary:
        var copy := {}
        for key in value:
            if key.begins_with(
                    FrameworkManifestSchema._PROPERTY_TYPE_KEY_PREFIX):
                continue
            if key.begins_with(FrameworkManifestSchema._CUSTOM_TYPE_KEY_PREFIX):
                continue
            copy[key] = _filter_out_meta_keys(value[key])
        return copy
    elif value is Array:
        var copy := []
        copy.resize(value.size())
        for i in value.size():
            copy[i] = _filter_out_meta_keys(value[i])
        return copy
    else:
        return value


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
        _clean_dictionary_property(
                key,
                type,
                local_properties,
                config_key_prefix)


func _clean_array_values(
        local_properties: Array,
        schema_type,
        config_key_prefix := "") -> void:
    # Remove any invalid-typed entries from the array.
    for i in local_properties.size():
        if !FrameworkManifestSchema \
                .get_is_expected_type(local_properties[i], schema_type):
            local_properties.remove(i)
            i -= 1
    
    if schema_type is Dictionary:
        for i in local_properties.size():
            _clean_dictionary_values(
                    local_properties[i],
                    schema_type,
                    config_key_prefix + "[%d]>" % i)
    elif schema_type is Array:
        assert(schema_type.size() == 1)
        for i in local_properties.size():
            _clean_array_values(
                    local_properties[i],
                    schema_type[0],
                    config_key_prefix + "[%d]>" % i)


func _clean_dictionary_property(
        key: String,
        type,
        local_properties: Dictionary,
        config_key_prefix: String) -> void:
    if key.begins_with(FrameworkManifestSchema._CUSTOM_TYPE_KEY_PREFIX):
        # This custom-type entry will be handled in the UI.
        return
    
    # Ensure an entry exists for this key.
    if !local_properties.has(key):
        local_properties[key] = \
                FrameworkManifestSchema.get_default_value(type)
    var saved_value = local_properties[key]
    
    # Ensure this value is the correct type.
    if !FrameworkManifestSchema.get_is_expected_type(saved_value, type):
        Sc.logger.warning(
                ("Invalid value saved in manifest dictionary: " +
                "%s%s => %s (actual: %s, expected: %s)") % [
                    config_key_prefix,
                    key,
                    str(saved_value),
                    str(FrameworkManifestSchema.get_type_string(
                        typeof(saved_value))),
                    str(FrameworkManifestSchema.get_type_string(type)),
                ])
        local_properties[key] = \
                FrameworkManifestSchema.get_default_value(type)
        saved_value = local_properties[key]
    
    # Record an additional entry to indicate the value's type.
    # (This is needed for rendering the correct editor controls for null
    # values.)
    local_properties[
            FrameworkManifestSchema._PROPERTY_TYPE_KEY_PREFIX + key] = type
    
    # Create children values.
    if type is Dictionary:
        _clean_dictionary_values(
                saved_value,
                type,
                config_key_prefix + key + ">")
    elif type is Array:
        assert(type.size() == 1)
        _clean_array_values(
                saved_value,
                type[0],
                config_key_prefix + key + ">")


func _clean_array_element(
        i: int,
        type,
        local_properties: Array,
        config_key_prefix := "") -> void:
    # Ensure an entry exists for this key.
    if local_properties.size() <= i:
        local_properties.resize(i + 1)
        local_properties[i] = FrameworkManifestSchema.get_default_value(type)
    var saved_value = local_properties[i]
    
    # Ensure this value is the correct type.
    if !FrameworkManifestSchema.get_is_expected_type(saved_value, type):
        Sc.logger.warning(
                ("Invalid value saved in manifest array: " +
                "%s[%d] => %s (actual: %s, expected: %s)") % [
                    config_key_prefix,
                    i,
                    str(saved_value),
                    str(FrameworkManifestSchema.get_type_string(
                        typeof(saved_value))),
                    str(FrameworkManifestSchema.get_type_string(type)),
                ])
        local_properties[i] = FrameworkManifestSchema.get_default_value(type)
        saved_value = local_properties[i]
    
    # Create children values.
    if type is Dictionary:
        _clean_dictionary_values(
                saved_value,
                type,
                "%s[%d]>" % [config_key_prefix, i])
    elif type is Array:
        assert(type.size() == 1)
        _clean_array_values(
                saved_value,
                type[0],
                "%s[%d]>" % [config_key_prefix, i])
