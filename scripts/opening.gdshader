shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

instance uniform float start_time;

void fragment() {
    float T1 = .3;
    float length_1 = .3;
    float T2 = 1.;
    float length_2 = 1. - length_1;
    float diff = T2 - T1;
    float thresh;
    float t = TIME - start_time;
    if (t < T1)
        thresh = length_1 * smoothstep(0., T1, t);
    else if (t < T2)
        thresh = length_1;
    else
        thresh = length_1 + length_2 * smoothstep(T1, T2, t - diff);

    if(abs(UV.y - 0.5) < thresh)
        COLOR = vec4(0);
    else
        COLOR = vec4(0,0,0,1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
