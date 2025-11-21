shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE;

uniform float scale = 1.0; // multiplier for blur spread

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 px = SCREEN_PIXEL_SIZE * scale;
	
	
    float kernel[49] = float[](
         0.0,  1.0,  2.0,  3.0,  2.0,  1.0,  0.0,
         1.0,  4.0,  7.0,  9.0,  7.0,  4.0,  1.0,
         2.0,  7.0, 11.0, 14.0, 11.0,  7.0,  2.0,
         3.0,  9.0, 14.0, 18.0, 14.0,  9.0,  3.0,
         2.0,  7.0, 11.0, 14.0, 11.0,  7.0,  2.0,
         1.0,  4.0,  7.0,  9.0,  7.0,  4.0,  1.0,
         0.0,  1.0,  2.0,  3.0,  2.0,  1.0,  0.0
    );

    vec3 sum = vec3(0.0);
    int i = 0;

    for (int y = -3; y <= 3; y++) {
        for (int x = -3; x <= 3; x++) {
            vec2 offset = vec2(float(x), float(y)) * px;
            sum += texture(SCREEN_TEXTURE, uv + offset).rgb * kernel[i];
            i++;
        }
    }

    vec4 blured_color = vec4(sum / 256.0, 1.0);
    vec4 actual_color = texture(SCREEN_TEXTURE, uv);
	float ratio = max(min(1.,scale), 0.);
	COLOR = blured_color;
}
