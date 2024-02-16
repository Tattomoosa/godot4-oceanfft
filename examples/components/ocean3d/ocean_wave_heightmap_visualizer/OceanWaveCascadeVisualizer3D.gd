@tool
extends Node3D

# TODO lots of issues here
# - can only make 2 wave meshes that get visible materials?
# - ocean material gets offset somewhere else, check its shader
#   - need to change the height shader and add it
#   - need to add a shader to cascade previews that respects this offset

@export var reset: bool:
	set(value):
		_ready()

@export var ocean: Ocean3D:
	set(value):
		ocean = value
		_ready()

@export var y := -20.0:
	set(value): 
		y = value
		_ready()

# TODO: gap means ocean will not match up, uv-wise
@export var gap := 0:
	set(value): 
		gap = value
		_ready()

@export var height_map_shader : ShaderMaterial

var plane_mesh := PlaneMesh.new()
var subdivided_plane_mesh := PlaneMesh.new()

func _ready():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	if !ocean:
		return

	await get_tree().process_frame

	var width := ocean.horizontal_dimension
	var offset := width + gap
	var x_offset = 0
	var size = Vector2.ONE * width
	plane_mesh.size = size
	subdivided_plane_mesh.size = size
	subdivided_plane_mesh.subdivide_depth = width
	subdivided_plane_mesh.subdivide_width = width
	for texture in ocean.get_all_waves_textures():
		var z_offset := 0
		add_child(_make_flat_cascade_preview(texture, x_offset, z_offset))
		add_child(_make_ocean_preview(x_offset, z_offset))

		z_offset += offset
		add_child(_make_heightmap_cascade_preview(texture, x_offset, z_offset))
		add_child(_make_ocean_preview(x_offset, z_offset))

		z_offset += offset
		x_offset += offset

func _make_flat_cascade_preview(texture: Texture2D, x_offset: float, z_offset: float) -> MeshInstance3D:
	var plane := MeshInstance3D.new()
	plane.mesh = plane_mesh
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	plane.material_override = material
	plane.position = Vector3(x_offset, y, z_offset)
	return plane

func _make_heightmap_cascade_preview(texture: Texture2D, x_offset: float, z_offset: float):
	var plane := MeshInstance3D.new()
	plane.mesh = subdivided_plane_mesh
	var material = height_map_shader.duplicate()
	material.set_shader_parameter("cascade_texture", texture)
	material.set_shader_parameter("cascade_displacements", ocean._waves_texture_cascade.duplicate())
	material.set_shader_parameter("cascade_uv_scales", ocean.cascade_scales.duplicate())
	material.set_shader_parameter("uv_scale", ocean._uv_scale)
	plane.material_override = material
	plane.position = Vector3(x_offset, y, z_offset)
	return plane

func _make_ocean_preview(x_offset: float, z_offset: float):
	# prints("making ocean preview. x_offset:", x_offset, "z_offset", z_offset)
	var plane := MeshInstance3D.new()
	plane.mesh = subdivided_plane_mesh
	plane.material_override = ocean.material
	plane.position = Vector3(x_offset, 0, z_offset)
	# prints("plane: ", plane, "position: ", plane.position)
	return plane