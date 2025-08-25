shader_type canvas_item;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);

    // Create a smooth circle mask
    float circle = smoothstep(0.5, 0.48, dist);

    // Sample the texture and apply the mask
    vec4 color = texture(TEXTURE, uv);
    color.a *= circle;

    COLOR = color;
}
