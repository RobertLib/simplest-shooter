void main() {
    float deltaX = sin(v_tex_coord.y * 3.14 + u_time) * 0.015;

    v_tex_coord.x += deltaX;

    gl_FragColor = texture2D(u_texture, v_tex_coord);
}
