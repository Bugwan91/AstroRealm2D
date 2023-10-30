shader_type canvas_item;

uniform sampler2D mix_texture : repeat_enable, hint_default_transparent;
uniform sampler2D mask_texture : repeat_enable;
uniform sampler2D shift_texture_x : filter_linear, repeat_enable;
uniform sampler2D shift_texture_y : filter_linear, repeat_enable;
uniform float glow = 0.0;
uniform float scale = 1.0;
uniform vec2 vp_size = vec2(1.0);
uniform vec2 zoom = vec2(1.0);
uniform vec2 offset;

void fragment() {
	//vec2 offset = vec2(TIME, 0.0) * 0.5;
	vec2 zoom_factor = ((zoom - vec2(1.0, 1.0)) * 0.5 + vec2(1.0, 1.0));
	vec2 base_zoomed_uv = (UV - vec2(0.5, 0.5)) * vp_size / (zoom_factor) + vec2(0.5, 0.5);
	vec2 base_uv = base_zoomed_uv + scale * offset;
	
	float mult_base = 16.0;
	float mult = mult_base;
	vec2 shift_total = vec2(0.0);
	vec2 shift_mix = vec2(1.0);
	//int i = 1;
	//for (; i <= 1; i += 1) {
	vec2 shift_zoomed_uv = (UV - vec2(0.5, 0.5)) * vp_size / (zoom_factor * mult)  + vec2(0.5, 0.5);
	vec2 shift_uv = shift_zoomed_uv + scale * offset / mult;
	vec2 shift = vec2(texture(shift_texture_x, shift_uv).r, texture(shift_texture_y, shift_uv).r);
	shift_total += (shift - 0.5);
	shift_mix += shift * shift;
	mult *= mult_base;
	//}
	vec4 base = texture(TEXTURE, base_uv + shift_total);
	vec4 mix_color = texture(mix_texture, 1.0 - (base_uv + shift_mix));
	vec4 final = mix(base, mix_color, 0.5) * texture(mask_texture, base_uv + shift_total);
	final = smoothstep(0.0, 1.0, final);
	COLOR = vec4(final.rgb + final.rgb * glow, smoothstep(0.0, 1.0, final.a));
}
