#version 460 core

in vec2 TexCoord;

layout(location = 0) out vec4 FragColor;

uniform sampler2D texture0;
uniform vec2 src_size;
uniform vec2 dst_size;
uniform vec2 blur_center;
uniform vec2 obj_center;
uniform int amount;
uniform int pixel_range;
uniform float quality;

void main() {
    vec2 xy = TexCoord * dst_size;
    xy += obj_center;

    vec2 center = blur_center - xy;
    int dist8 = int(distance(xy, blur_center)) * 8;
    int range = amount * dist8 / 1000;
    if (pixel_range < dist8) {
        range = pixel_range * amount / 1000;
        dist8 = pixel_range;
    }
    range = int(range * quality);
    dist8 = int(dist8 * quality);

    vec4 color = vec4(0.0);

    if (2 <= dist8 && 2 <= range) {
        for (int i = 0; i < range; i++) {
            vec2 itr = xy + i * center / dist8;
            if (0 <= itr.x && itr.x < src_size.x && 0 <= itr.y && itr.y < src_size.y) {
                vec4 col = texture(texture0, itr / src_size);
                color.a += col.a;
                color.rgb += col.rgb * col.a;
            }
        }
        float is_zero = step(color.a, 0.0);
        color.rgb = mix(color.rgb / max(color.a, 0.0001), vec3(0.0), is_zero);
        color.a /= range;
    } else if (0 <= xy.x && 0 <= xy.y && xy.x < src_size.x && xy.y < src_size.y) {
        color = texture(texture0, xy / src_size);
    }

    // これ以外はcolは0なので特別な処理は必要なし

    FragColor = clamp(color, 0.0, 1.0);
}
