@tool
class_name OceanDepthProbe3D
extends Node3D

## The ocean simulation that will be sampled for wave height.
@export var ocean: Ocean3D

## The highest index displacement cascade the wave height will be sampled from.
## lower numbers can be used to filter out smaller waves from a probes height
## sample. Useful for making a large object disregard small waves and only
## respond to larger swell waves.
@export_range(0, 20, 1) var max_cascade := 1

## The height sampling steps used when sampling the wave height textures. This
## is used to correct for the horizontal displacement that the waves include.
@export_range(0, 100, 1) var height_sampling_steps := 2

func get_wave_height() -> float:
	if !ocean:
		return 0.0
	return ocean.get_wave_height(global_position, max_cascade, height_sampling_steps)

func get_depth() -> float:
	return get_wave_height() - global_position.y