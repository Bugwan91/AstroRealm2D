shader_type canvas_item;

uniform sampler2D mask_texture : filter_linear_mipmap, repeat_enable;
uniform sampler2D shift_texture_x : filter_linear_mipmap, repeat_enable;
uniform float glow = 0.0;
uniform vec2 vp = vec2(1.0);
uniform vec2 offset;

void fragment() {
	vec2 base_uv = (UV - vec2(0.5, 0.5)) * vp + offset + vec2(0.5, 0.5);
	
	float mult_base = 0.5;
	float mult = 0.3;
	vec2 shift_total = vec2(0.0);
	vec2 shift_mix = vec2(1.0);
	int i = 1;
	for (; i <= 2; i += 1) {
		vec2 shift_uv = (base_uv - vec2(0.5, 0.5)) * mult  + vec2(0.5, 0.5);
		shift_total += vec2(texture(shift_texture_x, shift_uv).r, texture(shift_texture_x, shift_uv).r);
		mult *= mult_base;
	}
	vec4 color = texture(TEXTURE, base_uv + shift_total * 0.125);
	color.a = color.a * texture(mask_texture, base_uv + shift_total * 0.5).r;
	color.a = pow(color.a, 2.5);
	COLOR = vec4(color.rgb + color.rgb * glow, color.a);
}
