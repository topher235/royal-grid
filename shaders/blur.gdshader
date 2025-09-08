shader_type canvas_item;

uniform float blur_amount: hint_range(0.0, 5.0) = 1.0;
uniform float samples: hint_range(0.0, 40.0) = 9.0;

void fragment(){
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    for(float x = -1.0; x <= 1.0; x += 1.0) {
        for(float y = -1.0; y <= 1.0; y += 1.0) {
            vec2 offset = vec2(x, y) * blur_amount / vec2(textureSize(TEXTURE, 0));
            vec4 sample_color = texture(TEXTURE, UV + offset);
            color += sample_color;
        }
    }

    color = color / samples;

    // Force black color but preserve alpha
    COLOR = vec4(0.0, 0.0, 0.0, color.a);
}