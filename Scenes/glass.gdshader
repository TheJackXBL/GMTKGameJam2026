shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment()
{
    vec2 offset = vec2(0.01, 0.0);

    COLOR = texture(screen_texture, SCREEN_UV + offset);
}