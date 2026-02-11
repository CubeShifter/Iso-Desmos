shader_type canvas_item;

uniform bool enabled = false;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (enabled) {
		COLOR = vec4(1,1,1,tex.a);
	} else {
		COLOR = tex;
	}
    
}
