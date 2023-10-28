shader_type canvas_item;

uniform float glow = 1.0;
uniform float scale = 1.0;
uniform vec2 vp_size = vec2(1.0);
uniform vec2 zoom = vec2(1.0);
uniform vec2 offset;

void fragment() {
	vec2 zoom_factor = ((zoom - vec2(1.0, 1.0)) * 0.5 + vec2(1.0, 1.0));
	vec2 base_zoomed_uv = (UV - vec2(0.5, 0.5)) * vp_size / (zoom_factor) + vec2(0.5, 0.5);
	vec2 base_uv = base_zoomed_uv + scale * offset;
	
	vec4 color = texture(TEXTURE, base_uv);
	color += color * glow * 2.0 / (zoom_factor.x + zoom_factor.y);
	COLOR = color;
}
