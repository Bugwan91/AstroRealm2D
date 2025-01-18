shader_type canvas_item;
render_mode unshaded;

uniform vec4 color: source_color = vec4(1.0);
uniform float brightness = 1.0;
uniform float rotation_speed = 0.02;

void fragment() {
	float px = 2.0 * (UV.x - 0.5);
	float py = 2.0 * (UV.y - 0.5);

	if (px * px + py * py > 1.0) {
		COLOR.a = 0.0;
	} else {
		float dx = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
		//float dy = asin(py / sqrt(1.0 - px * px)) * 2.0 / PI;
		float dy = asin(py) * 2.0 / PI;

		float tex_color = texture(TEXTURE, vec2(
			0.5 * (dx + 1.0) - TIME * rotation_speed,
			0.5 * (dy + 1.0))).r + texture(TEXTURE, vec2(
				0.5 * (0.5 * dx + 1.0) - sin(TIME * rotation_speed * 0.5),
				0.5 * (0.5 * dy + 1.0) + sin(TIME * rotation_speed * 0.5)
			)).r;
		vec4 sun_color = color * tex_color * tex_color;
		COLOR = (sun_color + sun_color * pow(px * px + py * py, 2.0)) * brightness;
	}
}