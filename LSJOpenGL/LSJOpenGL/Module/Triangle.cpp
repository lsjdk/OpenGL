//
//  Triangle.cpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/2.
//

#include "Triangle.hpp"

void Triangle::modulChangeSize(int w,int h) {
    printf("-=-=-=-=modulChangeSize-=-=23-==");
}

void Triangle :: modulRenderScene() {
    
        //1.清除一个或者一组特定的缓存区
        /*
         缓冲区是一块存在图像信息的储存空间，红色、绿色、蓝色和alpha分量通常一起分量通常一起作为颜色缓存区或像素缓存区引用。
         OpenGL 中不止一种缓冲区（颜色缓存区、深度缓存区和模板缓存区）
          清除缓存区对数值进行预置
         参数：指定将要清除的缓存的
         GL_COLOR_BUFFER_BIT :指示当前激活的用来进行颜色写入缓冲区
         GL_DEPTH_BUFFER_BIT :指示深度缓存区
         GL_STENCIL_BUFFER_BIT:指示模板缓冲区
         */
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    
    
        //2.设置一组浮点数来表示红色
        GLfloat vRed[] = {1.0,0.0,0.0,1.0f};
    
        //传递到存储着色器，即GLT_SHADER_IDENTITY着色器，这个着色器只是使用指定颜色以默认笛卡尔坐标第在屏幕上渲染几何图形
        shaderManager.UseStockShader(GLT_SHADER_IDENTITY,vRed);
    
        //提交着色器
        triangleBatch.Draw();
}

void Triangle :: modulSpecialKeys(int key, int x, int y) {
    
}

void Triangle :: modulsetupRC() {
    //设置清屏颜色（背景颜色）
    glClearColor(0.98f, 0.40f, 0.7f, 1);
    
    
    //没有着色器，在OpenGL 核心框架中是无法进行任何渲染的。初始化一个渲染管理器。
    //在前面的课程，我们会采用固管线渲染，后面会学着用OpenGL着色语言来写着色器
    shaderManager.InitializeStockShaders();
    
    
    //指定顶点
    //在OpenGL中，三角形是一种基本的3D图元绘图原素。
    GLfloat vVerts[] = {
        -0.5f,0.0f,0.0f,
        0.5f,0.0f,0.0f,
        0.0f,0.5f,0.0f
    };
    
    triangleBatch.Begin(GL_TRIANGLES, 3);
    triangleBatch.CopyVertexData3f(vVerts);
    triangleBatch.End();
}


