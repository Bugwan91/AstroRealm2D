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
		return 16.0 * ht_color.a * ht_val * ht_val * ht_color.rgb;
	}
	return vec3(0.0);
}

vec3 compute_diffuse(vec3 L, vec3 N, vec3 B_color, vec3 L_color) {
	float NdotL = clamp(dot(N, L), .0, 1.);
	return B_color * L_color * NdotL;
}

vec3 compute_specular(vec3 L, vec3 N, vec3 B_color, vec3 L_color, float Spec, float Met) {
	vec3 V = vec3(.0,.0,1.);
	vec3 R = (reflect(-L, N) + 3. * V) * 0.25; // vector of reflected light
	float RdotV = clamp(dot(R, V), 1e-4, 1.);
	float S = Spec * Spec;
	float shini = 1. + 256. * S;
	float intens = 0.3 * (
		// base specular intensity
		shini * pow(RdotV, shini)
		// extra wide reflections for metallic
		// as it is too dark in not bright spots without diffuse
		+ 4. * Met * pow(RdotV, 1. + 8. * S)
		// Shininess nagnitude increasing depending on specular and metalnes
		) * (S + Met) * 0.5;
	float fresnel = pow(1.0 - dot(N, V), 0.7) * Met * (1.5 - S * 0.5);
	return mix(vec3(0.5), B_color, Met) * L_color * (intens + fresnel);
}

void light() {
	// Mask texture for specular and metallic
	vec3 mask = texture(mask_texture, UV).rgb;
	float spec = mask.g + (1. - mask.g) * shininess * mask.r;
	float met = mask.b + (1. - mask.b) * metallic * mask.r;

	// Diffuse and specular light
		vec3 diffuse = compute_diffuse(
		LIGHT_DIRECTION,
		NORMAL,
		COLOR.rgb,
		LIGHT_COLOR.rgb
	);
    vec3 specular = compute_specular(
		LIGHT_DIRECTION,
		NORMAL,
		COLOR.rgb,
		LIGHT_COLOR.rgb,
		spec,
		met
	);

	// Heat effect
	float ht_tex = texture(heat_texture, UV).r * heat;
	vec3 ht = compute_heat(ht_tex);

	// Emission effect
	vec3 em = texture(emission_texture, UV).rgb * emission_color.rgb * emission;

	// Total light
	LIGHT = vec4(
		(
			// no diffuse for metallic
			diffuse * (1.0 - met) +
			// extra specular for metallic for consistant brightnes
			specular * (1.0 + met)
		) * LIGHT_ENERGY
		// extra lightning from heat and emmision
		+ ht + em,
		LIGHT_COLOR.a);
}
