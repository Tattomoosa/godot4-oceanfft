@tool
extends EditorInspectorPlugin

const CONTROL_SCENE : PackedScene = preload("res://addons/tessarakkt.oceanfft/inspector_plugins/ocean3d_inspector/ocean3d_inspector_plugin_controls.tscn")

func _can_handle(object: Object) -> bool:
	return object is Ocean3D

func _parse_begin(object: Object) -> void:
	var ocean := object as Ocean3D
	add_custom_control(CONTROL_SCENE.instantiate())

# func _parse_property(
# 	object: Variant,
# 	type,
# 	hint_type,
# 	hint_string,
# 	usage_flags,
# 	wide
# ):
# 	if object is Ocean3D:
# 		add_property_editor(name)