shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(screen_texture, SCREEN_UV);
	COLOR = vec4(tex.r, tex.g, tex.b, tex.a);

	if (COLOR.r > 0.25) {
		COLOR = vec4(tex.b, tex.g, tex.r, tex.a);
	} else if (COLOR.b > 0.25) {
		COLOR = vec4(tex.r, tex.b, tex.g, tex.a);
	} else if (COLOR.g > 0.25) {
		COLOR = vec4(tex.g, tex.r, tex.b, tex.a);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
