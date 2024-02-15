@tool
extends Node3D

@export var click_to_update: bool :
	set(_value):
		create_depth_probes()

@export var distance := Vector3(20, 20, 20)
@export var start_position := Vector3(-100, -100, -100)
@export var min_cascades := 1
@export var max_cascades := 3
@export var min_steps := 1
@export var max_steps := 10

@export var probe_scene : PackedScene
@export var ocean : Ocean3D

func _ready() -> void:
	create_depth_probes()
	property_list_changed.connect(create_depth_probes)

# Upon modification to any property, re-create depth probes
# Not working?
# func _set(_property: StringName, _value: Variant) -> bool:
# 	print("in set")
# 	create_depth_probes()
# 	return true

func create_depth_probes() -> void:
	print("creating depth probes")
	# clear
	for child in get_children():
		child.queue_free()
	if !probe_scene:
		return
	var pos := start_position
	for cascade in range(min_cascades, max_cascades + 1):
		for step in range(min_steps, max_steps):
			var probe : OceanDepthProbe3D = probe_scene.instantiate() 
			probe.position = pos
			probe.max_cascade = cascade
			probe.height_sampling_steps = step
			probe.ocean = ocean
			add_child(probe)
			pos.z += distance.z
		pos.z = start_position.z
		pos.y += distance.y
		pos.x += distance.x

