@tool
@icon("res://addons/tessarakkt.oceanfft/icons/MotorVesselBody3D.svg")
extends BuoyancyBody3D
class_name MotorVesselBody3D
## Physics Body which is moved by 3D physics simulation, and interacts with
## buoyancy provided by an Ocean3D. Can be moved around with a simple single
## propeller/rudder configuration.


@export var thrust_power_main := 10.0
@export var max_rudder_force := 10.0

## Propeller object. If null will use the MotorVesselBody3D's position for calculations
@export var propeller:Node3D
## Rudder object. If null will use the MotorVesselBody3D's position for calculations
@export var rudder:Node3D


func _process(delta):
	if Engine.is_editor_hint():
		return
	if !ocean:
		# Prints BuoyancyBody3D warning from its _physics_process, no need to warn again here
		return
	var propeller_global_position = _get_propeller_global_position()
	if ocean.get_wave_height(propeller_global_position) > propeller_global_position.y:
		var prop_horizontal := -global_transform.basis.z
		prop_horizontal.y = 0.0
		prop_horizontal = prop_horizontal.normalized()
		var prop_dot := prop_horizontal.dot(-global_transform.basis.z)
		
		if Input.is_action_pressed("ship_thrust_main_forwards"):
			apply_force(-global_transform.basis.z * thrust_power_main * prop_dot, propeller_global_position - global_position)
		elif Input.is_action_pressed("ship_thrust_main_backwards"):
			apply_force(global_transform.basis.z * thrust_power_main * prop_dot, propeller_global_position - global_position)
	
	var rudder_global_position = _get_rudder_global_position()
	if ocean.get_wave_height(rudder_global_position) > rudder_global_position.y:
		if Input.is_action_pressed("ship_steering_main_left"):
			apply_force(global_transform.basis.x * max_rudder_force, rudder_global_position - global_position)
		elif Input.is_action_pressed("ship_steering_main_right"):
			apply_force(-global_transform.basis.x * max_rudder_force, rudder_global_position - global_position)

func _get_propeller_global_position():
	if propeller:
		return propeller.global_position
	return global_position

func _get_rudder_global_position():
	if rudder:
		return rudder.global_position
	return global_position