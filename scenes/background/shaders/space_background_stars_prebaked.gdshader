shader_type canvas_item;

uniform float glow = 10.0;
uniform vec2 vp = vec2(1.0);
uniform vec2 offset;

void fragment() {
	vec2 base_uv = (UV - vec2(0.5, 0.5)) * vp + offset + vec2(0.5, 0.5);
	
	vec4 color = texture(TEXTURE, base_uv);
	color += color * glow;
	COLOR = color;
}
