extends Node3D

@export var ocean: Ocean3D
@export var max_cascade := 2
@export var steps := 2
@export var distance := 5.0
@export var count := Vector2i(20, 20)

var mesh := PointMesh.new()

func _ready():
	mesh.material = StandardMaterial3D.new()
	mesh.material.use_point_size = true
	mesh.material.point_size = 4.0

	for x in count.x:
		for y in count.y:
			var instance := MeshInstance3D.new()
			instance.position = Vector3(x * distance, 0, y * distance)
			instance.mesh = mesh
			add_child(instance)

func _physics_process(_delta):
	for instance in get_children():
		instance.global_position.y = ocean.get_wave_height(instance.global_position, max_cascade, steps)
