@tool
@icon("res://addons/tessarakkt.oceanfft/icons/BuoyancyProbe3D.svg")
extends OceanDepthProbe3D
class_name BuoyancyProbe3D
## Buoyancy probe used by BuoyancyBody3D to approximate an objects buoyancy.
##
## This is used as a wave height sampler by BuoyancyBody3D in order to do
## buoyancy calculations. It has no effect on its own, and must be added to a
## buoyancy body in order to provide an effect. This could also be used as a
## generic wave height sampler.

## The buoyancy multipler that applies to this probe only.
@export_range(0.0, 100.0) var buoyancy_multiplier := 1.0

# The BuoyancyBody3D this probe is being used by. Assigned automatically by seeking
# up the tree for a BuoyancyBody3D upon being added to the tree, and removed
# automatically when exiting the tree
var _buoyancy_body : BuoyancyBody3D = null


## Get the wave height at this buoyancy probes's location.
func get_wave_height() -> float:
	return ocean.get_wave_height(global_position, max_cascade, height_sampling_steps)

# Seeks up the scene tree for the first BuoyancyBody3D ancestor and adds itself to its active probes
func _add_to_buoyancy_body_3d_ancestor():
	var parent := get_parent()
	while parent:
		if parent is BuoyancyBody3D:
			parent.add_probe(self)
			_buoyancy_body = parent
			return
		parent = parent.get_parent()
	_buoyancy_body = null

func _enter_tree():
	_add_to_buoyancy_body_3d_ancestor()

func _exit_tree():
	if _buoyancy_body:
		_buoyancy_body.remove_probe(self)

func _get_configuration_warnings():
	const _NO_BODY_CONFIGURATION_WARNING :=\
		"BuoyancyProbe3D only serves to provide a buoyancy probe to a BuoyancyBody3D derived node.
		Please ensure it has a BuoyancyBody3D as an ancestor in the scene tree"

	if !_buoyancy_body:
		return [_NO_BODY_CONFIGURATION_WARNING]
