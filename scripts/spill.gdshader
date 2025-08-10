shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 color : source_color;
uniform sampler2D perlin;
instance uniform float start_time;
instance uniform float end_time = -1.;
instance uniform float base_wait_time;
instance uniform float spill_transparency = 1;
void fragment() {
    vec2 uv = UV - mod(UV, 0.03);

    float perlin_value = texture(perlin, uv).x;
    float d_to_middle = length(uv - vec2(0.5, 0.5));
    perlin_value += 1. - d_to_middle*3.;
    float elapsed_time = min(base_wait_time, TIME - start_time);
    if (end_time > 0.)
        elapsed_time = min(base_wait_time, end_time - start_time);
    float t = 1.5 - elapsed_time / 3.;
    if (perlin_value > t)
    {
        COLOR = color;
    }
    else
    {
        COLOR = vec4(0);
        discard;
    }
    if (TIME - start_time > base_wait_time)
        COLOR.a = mix(1,0,spill_transparency);
}
