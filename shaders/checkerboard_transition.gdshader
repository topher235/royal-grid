shader_type canvas_item;

// Progress of the transition (0.0 = fully transparent, 1.0 = fully opaque)
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Size of the checkerboard squares
uniform vec2 grid_size = vec2(8.0, 8.0);

// Color of the transition overlay
uniform vec4 transition_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Smoothness of the edge
uniform float smoothness : hint_range(0.0, 1.0) = 0.1;

// Direction of the wipe (0 = left-to-right, 1 = top-to-bottom, 2 = diagonal)
uniform int direction : hint_range(0, 2) = 2;

// Invert the transition (false = fade in, true = fade out)
uniform bool invert = false;

void fragment() {
    vec2 uv = UV;

    // Calculate checkerboard pattern
    vec2 grid_uv = fract(uv * grid_size);
    float checker = step(0.5, mod(floor(uv.x * grid_size.x) + floor(uv.y * grid_size.y), 2.0));

    // Calculate sweep position based on direction
    float sweep_position;
    if (direction == 0) {
        // Left to right
        sweep_position = uv.x;
    } else if (direction == 1) {
        // Top to bottom
        sweep_position = uv.y;
    } else {
        // Diagonal (bottom-left to top-right)
        sweep_position = (uv.x + uv.y) * 0.5;
    }

    // Add checker offset to create staggered effect
    float offset = checker * 0.1;

    // Calculate alpha based on progress and position
    float threshold = progress + offset;
    float alpha = smoothstep(sweep_position - smoothness, sweep_position + smoothness, threshold);

    // Invert if needed (for fade out - continues in same direction but removes instead of adds)
    if (invert) {
        alpha = 1.0 - alpha;
    }

    // Output the transition color with calculated alpha
    COLOR = vec4(transition_color.rgb, alpha * transition_color.a);
}