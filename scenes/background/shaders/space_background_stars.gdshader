shader_type canvas_item;

uniform float glow = 1.0;
uniform float density : hint_range(0.0, 1.0, 0.001) = 0.9;
uniform sampler2D mask_texture : hint_default_transparent, filter_nearest, repeat_enable;
uniform sampler2D temperature_mask : filter_nearest, repeat_enable;
uniform float scale = 1.0;
uniform vec2 vp_size = vec2(1.0);
uniform vec2 zoom = vec2(1.0);
uniform vec2 offset;

vec4 getStarColor(float temperature) {
	vec4 color = vec4(0.0);
	color.r = 1.0 - temperature;
	color.b = temperature;
	color.g = color.r * color.b * 2.0;
	return color;
}

void fragment() {
	//vec2 offset = vec2(TIME, 0.0) * 0.1;
	vec2 zoom_factor = ((zoom - vec2(1.0, 1.0)) * 0.5 + vec2(1.0, 1.0));
	vec2 base_zoomed_uv = (UV - vec2(0.5, 0.5)) * vp_size / (zoom_factor) + vec2(0.5, 0.5);
	vec2 base_uv = base_zoomed_uv + scale * offset;
	
	vec4 color = vec4(0.0);
	
	float intensity = 0.0;
	float t_noise = texture(temperature_mask, 1.0 - base_uv).r;
	float radius = ceil(t_noise * 3.0);
	for (float x = -1.0; x < 1.1; x+=1.0 / radius) {
		for (float y = -1.0; y < 1.1; y+=1.0 / radius) {
			vec2 star_uv = base_uv + vec2(x, y) * radius / 4096.0;
			float base = texture(TEXTURE, star_uv).r;
			float mask = texture(mask_texture, star_uv).r;
			float noise = base * mask;
			noise = pow(noise, 5.0);
			
            if (noise > density) {
				intensity += 1.0 - smoothstep(0.0, 1.0, dot(vec2(x,y),vec2(x,y)) * radius );
				intensity *= intensity + (noise - density) * 5.0 * (2.0 - density);
			}
		}
	}
	
	//intensity += intensity * sin(TIME * 100.0 * t_noise + t_noise) * 0.3 * t_noise;
	float temperature = texture(temperature_mask, base_uv).r;
	color = getStarColor(temperature) * intensity;
	color += color * glow * 2.0 / (zoom_factor.x + zoom_factor.y);
	if (intensity > 0.0) {
		color.a = 1.0;
	}
	COLOR = color;
}
