#define LINE_THINNING_FACTOR 8.0
#define PI 3.1415926
#define NUM_CURVES 6

/*
  Calculates how close the given point is to the
  superformula curve specified by the given parameters.
  Note that just m is used instead of m1 and m2, since
  for a lot of interesting curves m1 and m2 are the same anyway.
*/ 
float shape(vec2 xy,  // input point
            float m,  // superformula parameters
            float n1,
            float n2,
            float n3,
            vec2 offset, // offset of the curve origin
            float rot,   // rotation around origin
            float scale) {
    xy += offset;
    
    /* Calculate 2d polar coordinates of the point. Note that phi needs to be
       in the 0..2pi range, so we shift the result of atan by pi for points
       with x < 0
     */
    float r   = length(xy) * (1.0/scale);
    float phi = atan(xy.y / xy.x) + (xy.x < .0 ? PI : 0.0) + rot;

    float f   = pow(pow(abs(cos(m * phi / 4.0)), n2) + pow(abs(sin(m * phi / 4.0)), n3), -1.0/n1);

	return max(0.0, 1.0 - LINE_THINNING_FACTOR * abs(r-f));
}

float deg2rad(float x) {
	return 180.0 * x / PI;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    /* Calculate coordinates for this pixel and apply aspect ratio correction*/
    vec2 xy = (2.0 * fragCoord/iResolution.xy - 1.0) * vec2(iResolution.x/iResolution.y, 1.0);
    xy *= 15.0;
	vec4 params[NUM_CURVES] = vec4[](
        vec4(5.0, 3.0, 7.0, 7.0),
        vec4(17.0, 5.0, 3.0, 3.0),
        vec4(4.0, 5.0, 17.0, 17.0),
        vec4(16.0, 2.0, 0.5, 16.0),
        vec4(1.0, 200.0, 1.0, 1.0),
		vec4(4.0, 12.0, 15.0, 15.0)
    );
    vec2 offsets[NUM_CURVES] = vec2[](
        vec2(7.0 * cos(iTime / 2.0), 8.0 * sin(iTime * 2.0)),
        vec2(7.0 * cos(iTime * 2.0), 7.0 * sin(iTime * 2.0)),
        vec2(10.0 * sin(iTime), 5.0 * cos(iTime)),
        vec2(2.0 * cos(iTime), 2.0 * sin(iTime)),
        vec2(2.0 * cos(iTime), 2.0 * sin(iTime)),
        vec2(10.0 * sin(iTime/8.0), 5.0 * cos(iTime*2.0))  
    );
    float rotations[NUM_CURVES] = float[](
        deg2rad(iTime / 50.0),
        deg2rad(iTime / 25.0),
        deg2rad(iTime / 10.0),
        deg2rad(iTime / 70.0),
        0.0,
        deg2rad(iTime / 20.0)
    );
    vec3 colors[NUM_CURVES] = vec3[](
        vec3(1.0, 1.0, 0.0),
        vec3(0.6, 0.5, 1.0),
        vec3(0.7, 0.5, 0.1),
        vec3(1.0, 0.0, 0.0),
        vec3(1.0, 1.0, 0.0),
		vec3(0.0, 1.0, 1.0)
    );
    float scales[NUM_CURVES] = float[](
        1.0,
        1.5,
        1.3,
        1.5,
        0.5,
        1.0);
    vec3 color = vec3(0.0);
    for(int i = 0; i < NUM_CURVES; ++i) {
    	color += colors[i] * shape(xy,
                                params[i][0],
								params[i][1],
                                params[i][2],
                                params[i][3],
                                offsets[i],
                                rotations[i],
                                scales[i]);
    }
    
    fragColor = vec4(color, 1.0);
}