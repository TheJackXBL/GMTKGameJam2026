shader_type canvas_item;

uniform float frostAmount = 1.0;
uniform float maxTint = 0.50;
uniform vec4 tintColor : source_color = vec4(0.7, 0.7, 0.7, 1.0);

void fragment()
{
	vec4 col = texture(TEXTURE, UV);

	float tintStrength = frostAmount * maxTint;

	col.rgb = mix(
		col.rgb,
		tintColor.rgb,
		tintStrength
	);

	COLOR = col;
}