shader_type canvas_item;

uniform sampler2D mask_texture : filter_linear_mipmap, repeat_enable;
uniform sampler2D shift_texture_x : filter_linear_mipmap, repeat_enable;
uniform float glow = 0.0;
uniform vec2 vp = vec2(1.0);
uniform vec2 offset;

void fragment() {
	vec2 base_uv = (UV - vec2(0.5, 0.5)) * vp + offset + vec2(0.5, 0.5);
	
	float mult_base = 0.5;
	float mult = 0.1;
	vec2 shift_total = vec2(0.0);
	vec2 shift_mix = vec2(1.0);
	int i = 1;
	for (; i <= 2; i += 1) {
		vec2 shift_zoomed_uv = (base_uv - vec2(0.5, 0.5)) * mult  + vec2(0.5, 0.5);
		vec2 shift_uv = shift_zoomed_uv;
		shift_total += vec2(texture(shift_texture_x, shift_uv).r, texture(shift_texture_x, shift_uv).r);
		mult *= mult_base;
	}
	//shift_total = vec2(0.0);
	vec4 color = texture(TEXTURE, base_uv + shift_total * 0.125);
	float mask_value = texture(mask_texture, base_uv * 0.125 + shift_total).r;
	color.a = color.a * mask_value;
	color = smoothstep(0.0, 1.0, color);
	COLOR = vec4(color.rgb + color.rgb * glow * color.a, color.a);
}
