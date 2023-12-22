void main() {
    vec2 uv = v_tex_coord;
    float blurAmount = 0.025;
    vec4 color = vec4(0.0);
    int samples = 5;
    float offset = blurAmount / float(samples) * 2.0;

    for (int i = -samples / 2; i <= samples / 2; ++i) {
        color += texture2D(u_texture, uv + vec2(0.0, float(i) * offset));
    }

    color /= float(samples + 1);

    gl_FragColor = color;
}
