shader_type canvas_item;

uniform float emission = 5.0;
uniform float shininess : hint_range(-1, 1) = 0.0;
uniform sampler2D emission_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D specular_texture : filter_nearest_mipmap, hint_default_black;

vec3 light_normal_compute(
		vec3 light_vec,
		vec3 normal,
		vec3 base_color,
		vec3 light_color,
		float specular
	) {
	vec3 view = vec3(0.0, 0.0, 1.0);
	vec3 L = light_vec;
	L.z = 0.1;
	L = normalize(L);
	float Nbase = max(0.0, dot(normal, L));
	vec3 NV = normalize(normal + view * 1.0);
	vec3 LV = normalize(L + view * 1.0);
	vec3 R = reflect(-LV, NV);
	float Rdot = smoothstep(0.0, 1.0, dot(R, view));
	float shini = pow(1.0 / (1.0 - specular), 2.0);
	Rdot = smoothstep(0.0, 1.0, Rdot);
	float spec = pow(Rdot, shini) * pow(specular, 2.0) * 1.5;
	spec = pow(spec, 3.0);
	vec3 LN = light_color * base_color * Nbase;
	vec3 LS = mix(light_color, base_color, 0.5) * spec;
	return LN + LS;
}

void fragment() {
	vec4 ship_color = texture(TEXTURE, UV);
	float emission_value = texture(emission_texture, UV).r * emission;
	COLOR = vec4(ship_color.rgb + ship_color.rgb * emission_value, ship_color.a);
}

void light() {
	float spec = texture(specular_texture, UV).r;
	spec = spec + (1.0 - spec) * shininess;
	vec4 emission_value = texture(emission_texture, UV);
	if (emission_value.r > 0.0) {
		LIGHT = vec4(0.0);
	} else {
		if (LIGHT_COLOR.r == 0.0 && LIGHT_COLOR.g == 0.0 && LIGHT_COLOR.b == 0.0) {
			LIGHT = COLOR * LIGHT_ENERGY;
		} else {
			LIGHT = vec4(light_normal_compute(
				LIGHT_DIRECTION,
				NORMAL,
				COLOR.rgb,
				LIGHT_COLOR.rgb * LIGHT_ENERGY,
				spec
				), LIGHT_COLOR.a);
		}
	}
}