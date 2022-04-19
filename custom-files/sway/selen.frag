#ifdef GL_ES
precision mediump float;
#endif

#ifdef GLSLVIEWER 
uniform float u_time;
uniform vec2 u_resolution;
#endif
#ifndef GLSLVIEWER
uniform float time;
uniform vec2 resolution;
#endif

// Control variables
const float scale_factor = 0.55;
const float squish_factor = 3.0;
const float time_factor = -0.025;
const float dim_factor = 0.2;

vec4 simpleAlphaCompositing (vec4 source, vec4 backdrop) {
	float final_alpha = source.a + backdrop.a * (1.0 - source.a);
	return vec4(
		(source.rgb * source.a + backdrop.rgb * backdrop.a * (1.0 - source.a)) / final_alpha,
		final_alpha
	);
}


vec4 getColor(vec4 input_color, float speed, float freq, float amp, vec2 uv, float phase_offset) {
#ifdef GLSLVIEWER
  float time = u_time;
#endif
  float y = uv.y + (time * time_factor * speed);
  float d = uv.x - amp * scale_factor * sin(phase_offset + y * squish_factor * freq);
  float value = clamp((0.01 / (d * d)) * dim_factor, 0.0, 1.0);
  input_color.a = value;
  return input_color;
}

void main( void ) {
#ifdef GLSLVIEWER
        float time = u_time;
        vec2 resolution = u_resolution;
#endif
        vec2 uv = (gl_FragCoord.xy * 2. - resolution) / resolution.y;
	float tmp_x = uv.x;
	float tmp_y = uv.y;
	uv.x = tmp_y;
	uv.y = tmp_x;
	vec4 background = vec4((24.0/255.0), (73.0/255.0), (86.0/255.0), 0.0);
        vec4 colors[3];
        colors[0] = vec4((250.0/255.0), (87.0/255.0), (80.0/255.0), 0.0);
        colors[1] = vec4((117.0/255.0),(185.0/255.0),(56.0/255.0), 0.0);
        colors[2] = vec4((70.0/255.0),(149.0/255.0),(247.0/255.0),0.0);
	// Relative travel speeds
        vec3 speeds = vec3(1.0, 1.2, 0.8);
	// Relative frequency
        vec3 freqs = vec3(1.0, 1.2, 0.8);
	// Relative amplitude
        vec3 amps = vec3(1.0, 1.5, 0.5);
	// Generate the color maps
        for (int i = 0; i < 3; i++) {
          colors[i] = getColor(colors[i], speeds[i], freqs[i], amps[i], uv, 0.0);
          background.a += colors[i].a;
        }
	// Mix the colors
	background.a = 1.0 - clamp(background.a, 0.0, 1.0);
	vec4 color = simpleAlphaCompositing(colors[0], vec4(0.0, 0.0, 0.0, 1.0));
	color = simpleAlphaCompositing(colors[1], color);
	color = simpleAlphaCompositing(colors[2], color);
	vec4 result = simpleAlphaCompositing(background, color);
	gl_FragColor = result;
}
