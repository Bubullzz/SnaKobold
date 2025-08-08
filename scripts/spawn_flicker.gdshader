shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
instance uniform float start_time;

void fragment() {
    if (COLOR.a == 0.)
        discard;
    float elapsed = TIME - start_time + .1;
    float trans_time = .2;
	float band_width = 0.13;
    float pos_in_trans = elapsed / trans_time;
    float space_between_two = .3;
    if (pos_in_trans < 2.)
        COLOR = mix(vec4(1), COLOR, abs(pos_in_trans - 1.));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
