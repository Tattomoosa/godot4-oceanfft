@tool
extends Node3D

enum VisualizerMode {
	MIN_TO_MAX,
	GRID
}

@export var visualizer_mode : VisualizerMode = VisualizerMode.MIN_TO_MAX
@export var click_to_update: bool :
	set(_value):
		create_depth_probes()

@export var distance := Vector3(20, 20, 20)
@export var start_position := Vector3(-100, -100, -100)
@export var min_cascades := 1
@export var max_cascades := 3
@export var min_steps := 1
@export var max_steps := 10
@export var grid_size := 5

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
	match visualizer_mode:
		VisualizerMode.MIN_TO_MAX:
			for cascade in range(min_cascades, max_cascades + 1):
				for steps in range(min_steps, max_steps + 1):
					_create_depth_probe(pos, cascade, steps)
					pos.z += distance.z
				pos.z = start_position.z
				pos.y += distance.y
				pos.x += distance.x
		VisualizerMode.GRID:
			for x_i in range(0, grid_size):
				pos.x = start_position.x + (distance.x * x_i)
				for z_i in range(0, grid_size):
					pos.z = start_position.z + (distance.z * z_i)
					_create_depth_probe(pos, min_cascades, min_steps)

func _create_depth_probe(pos: Vector3, cascade: int, steps: int):
	var probe : OceanDepthProbe3D = probe_scene.instantiate() 
	probe.position = pos
	probe.max_cascade = cascade
	probe.height_sampling_steps = steps
	probe.ocean = ocean
	add_child(probe)