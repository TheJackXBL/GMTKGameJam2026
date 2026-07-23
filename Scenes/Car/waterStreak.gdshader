shader_type canvas_item;

uniform float opacity = 0.5;

void fragment()
{
    vec4 tex = texture(TEXTURE, UV);

    float highlight = smoothstep(0.3,0.5,UV.x)
                    * (1.0-smoothstep(0.5,0.7,UV.x));

    tex.rgb += highlight * 0.2;

    tex.a *= opacity;

    COLOR = tex;
}