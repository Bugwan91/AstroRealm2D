shader_type canvas_item;

uniform sampler2D mask_texture : hint_default_transparent;
uniform sampler2D style_texture : hint_default_transparent;

void fragment() {
	vec4 ship_color = texture(TEXTURE, UV);
	vec4 style_color = texture(style_texture, UV);
	vec4 mask_value = texture(mask_texture, UV);
	if (mask_value.r == 0.0) {
		COLOR = ship_color;
	} else {
		COLOR = ship_color * style_color * mask_value.r;
	}
}