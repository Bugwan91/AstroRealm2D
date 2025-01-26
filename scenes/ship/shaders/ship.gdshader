shader_type canvas_item;

uniform float heat : hint_range(0, 1) = 0.0;
uniform float emission : hint_range(0, 10) = 2.0;
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float shininess : hint_range(-1, 1) = 0.0;
uniform float metallic : hint_range(-1, 1) = 0.0;
uniform sampler2D mask_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D emission_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D heat_texture : filter_nearest, hint_default_black;
global uniform sampler2D temperature_texture : filter_nearest, hint_default_black;

vec3 compute_heat(float ht_val) {
	if (ht_val > 0.0) {
		vec4 ht_color = texture(temperature_texture, vec2(ht_val));
		return 32.0 * ht_color.a * ht_val * ht_val * ht_color.rgb;
	}
	return vec3(0.0);
}

vec3 compute_diffuse(vec3 L, vec3 N, vec3 B_color, vec3 L_color, float Spec, float Met) {
	float NdotL = clamp(dot(N, L), .0, 1.);
	float intens = NdotL * max(1.0 - Met * 0.6, 1. - Spec);
	return B_color * L_color * intens;
}

vec3 compute_specular(vec3 L, vec3 N, vec3 B_color, vec3 L_color, float Spec, float Met) {
	vec3 V = vec3(.0,.0,1.);
	vec3 R = 0.1 * (reflect(-L, N) + 9. * V);
	float RdotV = clamp(dot(R, V), 1e-4, 1.);
	float S = Spec * Spec;
	float shini = mix(1., 256., S);
	float s_m = Spec + Spec * Met;
	float intens = pow(RdotV, shini) * mix(.0, 16., S) * S;
	float fresnel = pow(1.0 - dot(N, V), 3.) * Met;
	return mix(B_color * L_color, L_color * 0.5, Met) * (intens + fresnel);
}

void light() {
    // Mask texture for specular and metallic
    vec3 mask = texture(mask_texture, UV).rgb;
    float spec = mask.g + (1. - mask.g) * shininess;
    float met = mask.b + (1. - mask.b) * metallic;

	//float m = sin(TIME) * 0.5 + 0.5;
    // Diffuse and specular light
    vec3 diffuse = compute_diffuse(
		LIGHT_DIRECTION,
		NORMAL,
		COLOR.rgb,
		LIGHT_COLOR.rgb * LIGHT_ENERGY,
		spec,
		met
	);
    vec3 specular = compute_specular(
		LIGHT_DIRECTION,
		NORMAL,
		COLOR.rgb,
		LIGHT_COLOR.rgb * LIGHT_ENERGY,
		spec,
		met
	);

	// Heat effect
    float ht_val = texture(heat_texture, UV).r * heat;
    vec3 ht = compute_heat(ht_val);

    // Emission effect
    vec3 em = texture(emission_texture, UV).rgb * emission_color.rgb * emission;

    // Total light
    LIGHT = vec4(diffuse + specular + ht + em, LIGHT_COLOR.a);
}
