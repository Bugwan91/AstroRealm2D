shader_type canvas_item;
//render_mode blend_mix;

uniform float emission = 5.0;
uniform float shininess : hint_range(-1, 1) = -0.6;
uniform sampler2D emission_texture : filter_nearest_mipmap, hint_default_black;
uniform sampler2D specular_texture : filter_nearest_mipmap, hint_default_black;

vec3 light_normal_compute(vec3 light_vec, vec3 normal, vec3 base_color, vec3 light_color, float specular) {
	float cNdotL = max(0.0, dot(normal, light_vec));
	vec3 view = vec3(0.0, 0.0, 1.0);
	light_vec = normalize(light_vec + view * 1.2);
	vec3 refl = reflect(-light_vec, normal);
	float reflDot = smoothstep(0.0, 1.0, dot(refl, view));
	float shini = pow(1.0 / (1.0 - specular), 2.0);
	float spec = pow(reflDot, shini) * pow(specular, 2.0);
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
	float spec = texture(specular_texture, UV).r;
	spec = spec + (1.0 - spec) * shininess;
	vec4 emission_value = texture(emission_texture, UV);
	if (emission_value.r > 0.0) {
		LIGHT = vec4(0.0);
	} else {
		if (LIGHT_COLOR.r == 0.0 && LIGHT_COLOR.g == 0.0 && LIGHT_COLOR.b == 0.0) {
			LIGHT = COLOR * LIGHT_ENERGY;
		} else {
			LIGHT = vec4(light_normal_compute(LIGHT_DIRECTION, NORMAL, COLOR.rgb, LIGHT_COLOR.rgb * LIGHT_ENERGY, spec), LIGHT_COLOR.a);
		}
	}
}