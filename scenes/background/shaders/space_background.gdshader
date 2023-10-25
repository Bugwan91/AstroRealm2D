shader_type canvas_item;

uniform float scale = 1.0;
uniform float zoom = 1.0;
uniform vec2 offset;
uniform sampler2D mask_texture : repeat_enable;
uniform sampler2D shift_texture : repeat_enable;

void fragment() {
	vec4 color = vec4(0.0);
	float mult_base = 2.0;
	float mult = mult_base;
	int i = 1;
	for (; i < 5; i += 1) {
		vec2 shift_zoomed_uv = (UV - vec2(0.5, 0.5)) / (zoom * mult)  + vec2(0.5, 0.5);
		vec2 shift_uv = shift_zoomed_uv + offset * scale / mult;
		vec2 shift = texture(shift_texture, shift_uv).rg;
		vec4 base = texture(TEXTURE, shift);
		vec4 mask = texture(mask_texture, shift);
		color = mix(color, mask * base, 0.5);
		mult *= mult_base;
	}
	vec2 zoomed_uv = (UV - vec2(0.5, 0.5)) / zoom  + vec2(0.5, 0.5);
	vec2 mask_uv = zoomed_uv + offset * scale;
	//color = pow(color, vec4(1.0) / float(i));
	COLOR = color;// * texture(mask_texture, mask_uv) * texture(TEXTURE, color.rg);
		//mult *= mult;
		//mask_zoomed_uv = (UV - vec2(0.5, 0.5)) / (zoom * mult)  + vec2(0.5, 0.5);
		//mask_uv = mask_zoomed_uv + offset * scale / mult;
		//mask = texture(mask_texture, mask_uv, 0.0).r;
		//a = a + pow(mask + 0.5, 2.0) - 0.5;
	//};
	
	
	//vec2 zoomed_uv = (UV - vec2(0.5, 0.5)) / zoom + vec2(0.5, 0.5);
    //vec2 offset_uv = zoomed_uv + offset * scale;
	//vec4 base = texture(TEXTURE, offset_uv);
	//vec4 mask = texture(mask_texture, offset_uv);
	//base = base * mask * mask;
	
}



//shader_type canvas_item;
//
//uniform float scale = 1.0;
//uniform float zoom = 1.0;
//uniform vec2 offset;
//uniform sampler2D mask_texture : repeat_enable;
//
//void fragment() {
	//vec2 zoomed_uv = (UV - vec2(0.5, 0.5)) / zoom + vec2(0.5, 0.5);
    //vec2 offset_uv = zoomed_uv + offset * scale;
	//vec4 main = texture(TEXTURE, offset_uv);
	//vec2 mask_zoomed_uv;
	//vec2 mask_uv;
	//float mask;
	//float a = main.a;
	//float mult = 2.0;
	//int i = 1;
	//for (; i < 8; i += 1) {
		//mult *= mult;
		//mask_zoomed_uv = (UV - vec2(0.5, 0.5)) / (zoom * mult)  + vec2(0.5, 0.5);
		//mask_uv = mask_zoomed_uv + offset * scale / mult;
		//mask = texture(mask_texture, mask_uv, 0.0).r;
		//a = a + pow(mask + 0.5, 2.0) - 0.5;
	//};
	//a = pow(a / 8.0, 8.0);
	//main.a = a;
	//COLOR = main;
//}
//
//
//
