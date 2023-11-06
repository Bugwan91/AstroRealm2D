shader_type canvas_item;
//render_mode blend_mix;

uniform float emission = 0.5;
uniform sampler2D emission_texture : filter_nearest, hint_default_black;
uniform sampler2D specular_texture : filter_nearest, hint_default_black;

vec3 light_normal_compute(vec3 light_vec, vec3 normal, vec3 base_color, vec3 light_color, vec4 specular) {
	float cNdotL = max(0.0, dot(normal, light_vec));
	vec3 view = vec3(0.0, 0.0, 1.0);
	light_vec = normalize(light_vec + view * 1.2);
	vec3 refl = reflect(-light_vec, normal);
	float reflDot = smoothstep(0.0, 1.0, dot(refl, view));
	float shininess = pow(1.0 / (1.0 - specular.r), 2.0);
	float spec = pow(reflDot, shininess) * pow(specular.r, 2.0) * 2.0;
	vec3 norm_light = light_color * base_color * cNdotL;
	vec3 spec_light = mix(light_color, base_color, 0.8) * spec;
	return spec_light + norm_light;
}

void fragment() {
	vec4 ship_color = texture(TEXTURE, UV);
	float emission_value = texture(emission_texture, UV).r * emission;
	COLOR = vec4(ship_color.rgb + ship_color.rgb * emission_value, ship_color.a);
}

void light() {
	vec4 spec = texture(specular_texture, UV);
	vec4 emission_value = texture(emission_texture, UV);
	if (emission_value.r > 0.0) {
		LIGHT = vec4(0.0);
	} else {
		LIGHT = vec4(light_normal_compute(LIGHT_DIRECTION, NORMAL, COLOR.rgb, LIGHT_COLOR.rgb * LIGHT_ENERGY, spec), LIGHT_COLOR.a);
	}
}