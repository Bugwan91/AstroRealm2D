shader_type canvas_item;
render_mode blend_add;


uniform vec2 scale;
uniform float opacity = 0.1;
uniform vec2 offset;
uniform vec4 emission: source_color;
uniform sampler2D mask: hint_default_white;

void fragment() {
	vec2 new_uv = UV * scale + offset - (0.5 * scale);
	vec4 color = texture(TEXTURE, new_uv);
	float mask_color = texture(mask, UV).r * opacity;
	color.a = color.a * mask_color;
	COLOR = color * emission;
}

void light() {
	LIGHT = vec4(0.0);
}
