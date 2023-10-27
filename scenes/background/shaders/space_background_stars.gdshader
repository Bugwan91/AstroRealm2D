shader_type canvas_item;

uniform float star_density : hint_range(0,1) = 0.1;
uniform float star_brightness : hint_range(0,1) = 0.8;
uniform vec2 star_size_range = vec2(0.5, 1.0); // min and max size of stars

void fragment() {
	vec4 color = vec4(0.0);
	COLOR = color;
    // Seed for randomness
    //float seed = UV.x * UV.y;
    //
    //// Generate random values for star position and brightness
    //float rand_pos = fract(sin(seed) * 43758.5453);
    //float rand_brightness = fract(sin(seed * 2.0) * 43758.5453);
    //
    //// Determine if a star should be drawn at this pixel
    //if (rand_pos < star_density) {
        //float star_size = mix(star_size_range.x, star_size_range.y, rand_brightness);
        //float brightness = star_brightness * rand_brightness;
        //
        //// Create a simple circular star
        //float distance_to_center = length(UV - 0.5);
        //float star_alpha = smoothstep(star_size, star_size - 0.01, distance_to_center);
        //
        //color = vec4(vec3(brightness), star_alpha);
    //}
	//COLOR = color;
}
