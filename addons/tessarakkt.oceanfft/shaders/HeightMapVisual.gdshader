shader_type spatial;

#include "OceanCommon.gdshaderinc"

uniform sampler2D cascade_texture : hint_default_white;
uniform int cascade_index = 0;
uniform float amplitude_scale_min = 0.25;
uniform float amplitude_scale_max = 1.0;
uniform float amplitude_scale_fade_distance = 12000.0;

void vertex() {
	VERTEX.y = 1.0;
	float linear_dist = length(VERTEX - CAMERA_POSITION_WORLD);
	vec3 displacement = get_displacement(VERTEX.xz);
	VERTEX += displacement;
	float amplitude_fade_range = clamp(linear_dist, 0.0, amplitude_scale_fade_distance) / amplitude_scale_fade_distance;
	VERTEX.y *= mix(amplitude_scale_max, amplitude_scale_min, amplitude_fade_range);
}

void fragment() {
	ALBEDO = texture(cascade_texture, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
