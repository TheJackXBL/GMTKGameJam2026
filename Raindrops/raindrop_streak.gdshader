shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
	vec4 line_colour = COLOR;
	vec4 clear_screen = texture(screen_texture, SCREEN_UV);

	COLOR = vec4(
		clear_screen.rgb,
		clear_screen.a * line_colour.a
	);
}