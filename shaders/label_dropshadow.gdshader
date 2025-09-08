shader_type canvas_item;
render_mode blend_mix, unshaded;

// Drop shadow parameters
uniform float shadow_offset_x : hint_range(-50.0, 50.0) = 2.0;
uniform float shadow_offset_y : hint_range(-50.0, 50.0) = 2.0;
uniform float shadow_blur : hint_range(0.0, 10.0) = 1.0;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float shadow_alpha : hint_range(0.0, 1.0) = 0.5;

// Soft shadow parameters for mobile optimization
uniform int shadow_samples : hint_range(1, 8) = 4;

void fragment() {
    vec2 shadow_offset = vec2(shadow_offset_x, shadow_offset_y);
    vec4 final_color = vec4(0.0);
    
    // Sample the original texture
    vec4 original = texture(TEXTURE, UV);
    
    // Create soft shadow by sampling multiple points
    // This is more mobile-friendly than expensive blur operations
    float shadow_alpha_final = 0.0;
    
    for (int i = 0; i < shadow_samples; i++) {
        float angle = float(i) * 6.28318 / float(shadow_samples);
        vec2 sample_offset = shadow_offset + vec2(cos(angle), sin(angle)) * shadow_blur;
        vec2 shadow_uv = UV - sample_offset / vec2(textureSize(TEXTURE, 0));
        
        // Clamp UV coordinates to prevent sampling outside texture
        shadow_uv = clamp(shadow_uv, vec2(0.0), vec2(1.0));
        
        vec4 shadow_sample = texture(TEXTURE, shadow_uv);
        shadow_alpha_final += shadow_sample.a;
    }
    
    // Average the shadow samples
    shadow_alpha_final /= float(shadow_samples);
    
    // Apply shadow color and alpha
    vec4 shadow_color_final = shadow_color;
    shadow_color_final.a *= shadow_alpha_final * shadow_alpha;
    
    // Combine shadow and original
    final_color = mix(shadow_color_final, original, original.a);
    
    // Ensure we don't exceed the original alpha
    final_color.a = max(final_color.a, original.a);
    
    COLOR = final_color;
}