shader_type canvas_item;
render_mode unshaded;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;
uniform vec2 numberOfTiles = vec2(30, 16.875);
uniform vec2 pixelsPrTile = vec2(8, 8);

void fragment() {
	vec2 positionInSquare = UV * numberOfTiles;
	vec2 pixelPosition = round(positionInSquare * pixelsPrTile);
	vec2 frac = fract(pixelPosition / pixelsPrTile);
	vec2 direction = abs(frac - 0.5);

	if (direction.x + direction.y + UV.x + UV.y <= progress * 4.0f){
		if(!reverse){
			discard;
		}
	}
	else if (reverse){
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
