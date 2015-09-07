// u_texture1是etc的alpha数据也可以用ETC1压缩 by dannyhe
const char* ccShader_etc_shader_frag = STRINGIFY(
\n#ifdef GL_ES\n
precision mediump float;
\n#endif\n
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture1;

void main()
{
    vec4 color = texture2D(CC_Texture0, v_texCoord);
    color.a = texture2D(u_texture1, v_texCoord).r;
    gl_FragColor = color * v_fragmentColor; //支持Cocos opacity
}
);