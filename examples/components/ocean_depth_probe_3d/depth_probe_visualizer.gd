@tool
extends Node3D

@export var probe : OceanDepthProbe3D
@export var surface_indicator: MeshInstance3D

var depth_line_mesh: LineMesh3D
var depth_label: Label3D

func _ready():
	depth_line_mesh = LineMesh3D.new()
	add_child(depth_line_mesh)
	depth_label = Label3D.new()
	add_child(depth_label)
	depth_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	# depth_label.fixed_size = true
	depth_label.scale = Vector3.ONE * 10.0
	depth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _physics_process(_delta: float) -> void:
	if !probe:
		return
	global_position = probe.global_position
	var depth = probe.get_depth()
	var camera_forward = _get_camera().transform.basis.z
	depth_line_mesh.draw(
		Vector3.ZERO,
		Vector3.UP * depth,
		camera_forward
	)
	depth_label.global_position = probe.global_position + camera_forward.normalized().cross(-Vector3.UP) * 2
	depth_label.text = "Depth: " + str(snappedf(depth, 0.01)) + "\n"\
		+ "Cascades: " + str(probe.max_cascade) + "\n"\
		+ "Steps: " + str(probe.height_sampling_steps)
	
	if surface_indicator and probe:
		surface_indicator.global_position = probe.global_position + Vector3.UP * depth

func _get_camera() -> Camera3D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_viewport_3d().get_camera_3d()
	return get_viewport().get_camera_3d()

class LineMesh3D extends MeshInstance3D:
	var width := 0.2
	var color := Color.RED

	func _ready():
		mesh = ImmediateMesh.new()

	func draw(start_position: Vector3, end_position: Vector3, normal: Vector3) -> void:
		var m := mesh as ImmediateMesh
		m.clear_surfaces()
		m.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

		var uv := Vector2.ZERO
		# var width3d := normal.normalized().cross(Vector3.RIGHT) * width
		var width3d := normal.normalized().cross(Vector3.UP) * width
		# var width3d := Vector3.ONE * width

		for pos in [
			start_position - width3d,
			start_position + width3d,
			end_position - width3d,
			start_position + width3d,
			end_position + width3d,
			end_position - width3d,
		]:
			m.surface_set_normal(normal)
			m.surface_set_uv(uv)
			m.surface_add_vertex(pos)

		m.surface_end()
