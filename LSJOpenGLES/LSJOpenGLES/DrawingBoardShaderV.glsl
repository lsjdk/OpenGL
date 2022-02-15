attribute vec4 position;

uniform mat4 mvp;

uniform float pointSize;

uniform lowp vec4 vertexColor;

varying lowp vec4 color;

void main() {
    
    color = vertexColor;
    
    gl_Position = mvp * positon;
    gl_PointSize = pointSize;
}
