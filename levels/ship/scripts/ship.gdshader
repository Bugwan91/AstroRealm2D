shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D emission_texture : hint_default_black;

void fragment() {
	vec4 ship_color = texture(TEXTURE, UV);
	float emission_value = texture(emission_texture, UV).r;
	COLOR = ship_color + ship_color * emission_value;
}