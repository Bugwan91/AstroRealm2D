shader_type canvas_item;

uniform float heat : hint_range(0, 1) = 0.0;
uniform float emission : hint_range(0, 10) = 2.0;
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float shininess : hint_range(-1, 1) = 0.0;
uniform float metallic : hint_range(-1, 1) = 0.0;
uniform sampler2D mask_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D emission_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D heat_texture : filter_nearest_mipmap, hint_default_black;
global uniform sampler2D temperature_texture : filter_linear, hint_default_black;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec3 light_normal_compute(vec3 L, vec3 N, vec3 B_color, vec3 L_color, float Spec, float Met) {
	vec3 V = vec3(0.0, 0.0, 1.0); // View vector
	
	// Diffuse light
	float NdotL = clamp(dot(N, L), 0.0, 1.0);
	vec3 Dif_color = B_color * L_color * NdotL;
	// Specular
	vec3 R = reflect(-L, N);
	float shini = 2.0 / (1.0 - Spec * 0.999);
	float RdotV = clamp(dot(R, V), .0, 1.0);
	float area = pow(RdotV, shini);
	vec3 Spec_color = mix(B_color, L_color, Met) * area * clamp(shini * Spec, 0, 32.0);
	return Dif_color + Spec_color;
}

void light() {
	 //SPECULAR & METALLIC
	vec3 mask = texture(mask_texture, UV).rgb;
	float spec = mask.g + (1.0 - mask.g) * shininess;
	float met = mask.b + (1.0 - mask.b) * metallic;
	vec3 normal_spec = light_normal_compute(
		LIGHT_DIRECTION,
		NORMAL,
		COLOR.rgb,
		LIGHT_COLOR.rgb * LIGHT_ENERGY,
		spec,
		met
	);
	// HEAT
	float ht_base = texture(heat_texture, UV).r * heat;
	vec3 ht_val = vec3(0.0);
	if (ht_base > 0.0) {
		vec3 ht_color = texture(temperature_texture, vec2(ht_base)).rgb;
		ht_val = ht_color * pow(ht_base, 2.0) * 32.0;
		//ht_val *= 1.0 + 0.5 * ht_base;
	}
	// EMISSION / Probably, this should go to fragment shader.
	vec3 em_val = texture(emission_texture, UV).rgb * emission_color.rgb * emission;
	// TOTAL LIGHT
	LIGHT = vec4(normal_spec + em_val + ht_val, LIGHT_COLOR.a);
}