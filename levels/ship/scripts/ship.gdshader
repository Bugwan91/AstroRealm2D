shader_type canvas_item;

uniform sampler2D emission_texture : hint_default_transparent;

void fragment() {
	vec4 ship_color = texture(TEXTURE, UV);
	float emission_value = texture(emission_texture, UV).r;
	COLOR = ship_color + 2.0 * ship_color * emission_value;
}