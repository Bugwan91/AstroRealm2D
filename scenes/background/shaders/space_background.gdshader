shader_type canvas_item;


uniform sampler2D mask_texture : repeat_enable;
uniform sampler2D shift_texture_x : filter_linear, repeat_enable;
uniform sampler2D shift_texture_y : filter_linear, repeat_enable;
uniform float scale = 1.0;
uniform float zoom = 1.0;
uniform vec2 offset;

void fragment() {
	//vec2 offset = vec2(TIME, 0.0) * 0.1;
	vec2 base_zoomed_uv = (UV - vec2(0.5, 0.5)) / (zoom)  + vec2(0.5, 0.5);
	vec2 base_uv = base_zoomed_uv + offset * scale;
	
	float mult_base = 32.0;
	float mult = mult_base;
	vec2 shift_total = vec2(0.0);
	int i = 1;
	for (; i <= 4; i += 1) {
		vec2 shift_zoomed_uv = (UV - vec2(0.5, 0.5)) / (zoom * mult)  + vec2(0.5, 0.5);
		vec2 shift_uv = shift_zoomed_uv + offset * scale / mult;
		vec2 shift = vec2(texture(shift_texture_x, shift_uv).r, texture(shift_texture_y, shift_uv).r);
		shift_total += (shift - 0.5);
		mult *= mult_base;
	}
	vec4 base = texture(TEXTURE, base_uv + shift_total);
	vec4 mask = texture(mask_texture, base_uv + shift_total);
	vec4 final = base * mask;
	final.a = final.a * final.a;
	COLOR = final;
}
