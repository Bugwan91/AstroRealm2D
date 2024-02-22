shader_type canvas_item;

uniform sampler2D mask_texture : filter_nearest, hint_default_black;
uniform sampler2D style_texture : filter_nearest, hint_default_white;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float mask = texture(mask_texture, UV).r;
	vec4 style = texture(style_texture, UV);
	COLOR = mix(base, style, mask);
}