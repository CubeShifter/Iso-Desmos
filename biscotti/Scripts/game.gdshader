shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture;
uniform bool enabled = false;

void fragment() {
	vec4 p = texture(screen_texture, SCREEN_UV);
	if (!enabled) {
		COLOR = p;
		
		
		
	}else {
		COLOR = vec4(p.b,p.g,p.r,1);
	}
	
    
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
