shader_type canvas_item;

uniform float heat : hint_range(0, 1) = 0.0;
uniform float emission : hint_range(0, 10)= 2.0;
uniform vec3 emission_color : source_color;
uniform float shininess : hint_range(-1, 1) = 0.0;
uniform sampler2D mask_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D emission_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D heat_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D temperature_texture : filter_linear, hint_default_black;

vec3 light_normal_compute(
		vec3 light_vec,
		vec3 normal,
		vec3 base_color,
		vec3 light_color,
		float specular,
		float metallic
	) {
	vec3 view = vec3(0.0, 0.0, 1.0);
	vec3 L = light_vec;
	float Nbase = max(0.0, dot(normal, L));
	vec3 NV = normalize(normal + view * 1.0);
	vec3 LV = normalize(L + view * 1.0);
	//vec3 R = reflect(-LV, NV);
	vec3 R = reflect(-light_vec, normal);
	float Rdot = smoothstep(0.0, 1.0, dot(R, view));
	float shini = pow(1.0 / (1.0 - specular), 2.0);
	Rdot = smoothstep(0.0, 1.0, Rdot);
	float spec = pow(Rdot, shini) * pow(specular, 2.0) * 1.5;
	spec = pow(spec, 3.0);
	vec3 LN = light_color * base_color * Nbase;
	vec3 LS = mix(light_color, base_color, metallic) * spec;
	return LN + LS;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	// HEAT
	float ht_base = texture(heat_texture, UV).r * heat;
	vec3 ht_val = vec3(0.0);
	if (ht_base > 0.0) {
		vec3 ht_color = texture(temperature_texture, vec2(ht_base)).rgb;
		ht_val = pow(ht_color, vec3(2.0)) * pow(ht_base, 2.0) * 16.0;
	}
	// EMISSION
	vec3 em_val = texture(emission_texture, UV).rgb * emission_color * emission;
	em_val = pow(em_val, vec3(1.0 + emission));
	// TOTAL COLOR
	COLOR = vec4(color.rgb + ht_val + em_val, color.a);
}

void light() {
	if (LIGHT_COLOR.r == 0.0 && LIGHT_COLOR.g == 0.0 && LIGHT_COLOR.b == 0.0) {
		// HEAT
		float ht_base = texture(heat_texture, UV).r * heat;
		vec3 ht_val = vec3(0.0);
		if (ht_base > 0.0) {
			vec3 ht_color = texture(temperature_texture, vec2(ht_base)).rgb;
			ht_val = pow(ht_color, vec3(2.0)) * pow(ht_base, 2.0) * 16.0;
		}
		// EMISSION
		vec3 em_val = texture(emission_texture, UV).rgb * emission_color * emission;
		// TOTAL BASE LIGHT
		LIGHT = -(COLOR * smoothstep(0.0, 1.0, LIGHT_ENERGY))
			+ vec4(em_val + ht_val, 0.0);
	} else {
		// SPECULAR & METALLIC
		vec3 mask = texture(mask_texture, UV).rgb;
		float spec = mask.g + (1.0 - mask.g) * shininess;
		float metallic = smoothstep(0.0, 1.0, 1.0 - mask.b);
		LIGHT = vec4(light_normal_compute(
			LIGHT_DIRECTION,
			NORMAL,
			COLOR.rgb,
			LIGHT_COLOR.rgb * LIGHT_ENERGY,
			spec,
			metallic
			), LIGHT_COLOR.a);
	}
}