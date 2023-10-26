shader_type canvas_item;

const int max_colors = 16;

uniform vec3 color_targets[max_colors] : source_color;
uniform vec3 replacement_colors[max_colors] : source_color;
uniform float tolerance : hint_range(0.0, 1.0) = 0.01;

void fragment() {
    int index_of_closest;
    float distance_to_closest = 1.732;
    for (int i = 0; i < color_targets.length(); i++) {
        float d = distance(color_targets[i], COLOR.rgb);
        if (d < distance_to_closest) {
            index_of_closest = i;
            distance_to_closest = d;
        }
    }
     if (distance_to_closest < tolerance * 1.7320508076) {
        COLOR.rgb = replacement_colors[index_of_closest];
    }
}
