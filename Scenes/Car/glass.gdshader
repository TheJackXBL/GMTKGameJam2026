shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float frostAmount = 1.0;
uniform float distortion = 0.03;
uniform float blur = 0.01;

float rand(vec2 p)
{
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment()
{
    vec2 uv = SCREEN_UV;

    float noise = rand(UV * 500.0);

	vec2 offset = vec2(
    	noise - 0.5,
    	rand(UV * 500.0 + 17.0) - 0.5
	) * distortion * frostAmount;

    vec4 col = vec4(0.0);

float blurDistort = blur * frostAmount;
    col += texture(screen_texture, uv + offset);
    col += texture(screen_texture, uv + offset + vec2( blurDistort, 0.0));
    col += texture(screen_texture, uv + offset + vec2(-blurDistort, 0.0));
    col += texture(screen_texture, uv + offset + vec2(0.0, blurDistort));
    col += texture(screen_texture, uv + offset + vec2(0.0,-blurDistort));

    COLOR = col / 5.0;
}