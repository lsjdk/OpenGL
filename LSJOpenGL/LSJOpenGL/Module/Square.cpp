//
//  Square.cpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/3.
//

#include "Square.hpp"

//blockSize 边长
GLfloat blockSize = 0.1f;

//正方形的4个点坐标
GLfloat vVerts[] = {
        -blockSize,-blockSize,0.0f,
        blockSize,-blockSize,0.0f,
        blockSize,blockSize,0.0f,
        -blockSize,blockSize,0.0f
};


void Square::modulChangeSize(int w,int h) {
    printf("-=-=-=-=modulChangeSize-=-=23-==");
}

void Square :: modulRenderScene() {
    
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
//        GLfloat vRed[] = {1.0,0.0,0.0,1.0f};
//    
//        //传递到存储着色器，即GLT_SHADER_IDENTITY着色器，这个着色器只是使用指定颜色以默认笛卡尔坐标第在屏幕上渲染几何图形
//        shaderManager.UseStockShader(GLT_SHADER_IDENTITY,vRed);
//    
//        //提交着色器
//        triangleBatch.Draw();
    
    //定义4种颜色
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 0.5f };
    GLfloat vGreen[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    GLfloat vBlue[] = { 0.0f, 0.0f, 1.0f, 1.0f };
    GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    
    //召唤场景的时候，将4个固定矩形绘制好
    //使用 单位着色器
    //参数1：简单的使用默认笛卡尔坐标系（-1，1），所有片段都应用一种颜色。GLT_SHADER_IDENTITY
    //参数2：着色器颜色
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vGreen);
    greenBatch.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vRed);
    redBatch.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vBlue);
    blueBatch.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vBlack);
    blackBatch.Draw();
    
    
    //组合核心代码
    //1.开启混合
    glEnable(GL_BLEND);
    //2.开启组合函数 计算混合颜色因子
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //3.使用着色器管理器
    //*使用 单位着色器
    //参数1：简单的使用默认笛卡尔坐标系（-1，1），所有片段都应用一种颜色。GLT_SHADER_IDENTITY
    //参数2：着色器颜色
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, vRed);
    //4.容器类开始绘制
    squareBatch.Draw();
    //5.关闭混合功能
    glDisable(GL_BLEND);
}

void Square :: modulSpecialKeys(int key, int x, int y) {
    
    GLfloat stepSize = 0.025f;
    
    GLfloat blockX = vVerts[0];
    GLfloat blockY = vVerts[10];
    
    printf("v[0] = %f\n",blockX);
    printf("v[10] = %f\n",blockY);
    
    
    if (key == GLUT_KEY_UP) {
        
        blockY += stepSize;
    }
    
    if (key == GLUT_KEY_DOWN) {
        
        blockY -= stepSize;
    }
    
    if (key == GLUT_KEY_LEFT) {
        blockX -= stepSize;
    }
    
    if (key == GLUT_KEY_RIGHT) {
        blockX += stepSize;
    }

    //触碰到边界（4个边界）的处理
    
    //当正方形移动超过最左边的时候
    if (blockX < -1.0f) {
        blockX = -1.0f;
    }
    
    //当正方形移动到最右边时
    //1.0 - blockSize * 2 = 总边长 - 正方形的边长 = 最左边点的位置
    if (blockX > (1.0 - blockSize * 2)) {
        blockX = 1.0f - blockSize * 2;
    }
    
    //当正方形移动到最下面时
    //-1.0 - blockSize * 2 = Y（负轴边界） - 正方形边长 = 最下面点的位置
    if (blockY < -1.0f + blockSize * 2 ) {
        
        blockY = -1.0f + blockSize * 2;
    }
    
    //当正方形移动到最上面时
    if (blockY > 1.0f) {
        
        blockY = 1.0f;
        
    }
    
    
    
    printf("blockX = %f\n",blockX);
    printf("blockY = %f\n",blockY);
    
    // Recalculate vertex positions
    vVerts[0] = blockX;
    vVerts[1] = blockY - blockSize*2;
    
    printf("(%f,%f)\n",vVerts[0],vVerts[1]);
    
    
    vVerts[3] = blockX + blockSize*2;
    vVerts[4] = blockY - blockSize*2;
    printf("(%f,%f)\n",vVerts[3],vVerts[4]);
    
    vVerts[6] = blockX + blockSize*2;
    vVerts[7] = blockY;
    printf("(%f,%f)\n",vVerts[6],vVerts[7]);
    
    vVerts[9] = blockX;
    vVerts[10] = blockY;
    printf("(%f,%f)\n",vVerts[9],vVerts[10]);
    
    squareBatch.CopyVertexData3f(vVerts);
    
}

void Square :: modulSetupRC() {
//    //设置清屏颜色（背景颜色）
//    glClearColor(0.98f, 0.40f, 0.7f, 1);
//
//
//    //没有着色器，在OpenGL 核心框架中是无法进行任何渲染的。初始化一个渲染管理器。
//    //在前面的课程，我们会采用固管线渲染，后面会学着用OpenGL着色语言来写着色器
//    shaderManager.InitializeStockShaders();
//
//
//    //指定顶点
//    //在OpenGL中，三角形是一种基本的3D图元绘图原素。
//
//    //修改为GL_TRIANGLE_FAN ，4个顶点
//    triangleBatch.Begin(GL_TRIANGLE_FAN, 4);
//    triangleBatch.CopyVertexData3f(vVerts);
//    triangleBatch.End();
    
    
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f );
    shaderManager.InitializeStockShaders();

    //绘制1个移动矩形
    squareBatch.Begin(GL_TRIANGLE_FAN, 4);
    squareBatch.CopyVertexData3f(vVerts);
    squareBatch.End();
    
    //绘制4个固定矩形
    GLfloat vBlock[] = { 0.25f, 0.25f, 0.0f,
        0.75f, 0.25f, 0.0f,
        0.75f, 0.75f, 0.0f,
        0.25f, 0.75f, 0.0f};
    
    greenBatch.Begin(GL_TRIANGLE_FAN, 4);
    greenBatch.CopyVertexData3f(vBlock);
    greenBatch.End();
    
    
    GLfloat vBlock2[] = { -0.75f, 0.25f, 0.0f,
        -0.25f, 0.25f, 0.0f,
        -0.25f, 0.75f, 0.0f,
        -0.75f, 0.75f, 0.0f};
    
    redBatch.Begin(GL_TRIANGLE_FAN, 4);
    redBatch.CopyVertexData3f(vBlock2);
    redBatch.End();
    
    
    GLfloat vBlock3[] = { -0.75f, -0.75f, 0.0f,
        -0.25f, -0.75f, 0.0f,
        -0.25f, -0.25f, 0.0f,
        -0.75f, -0.25f, 0.0f};
    
    blueBatch.Begin(GL_TRIANGLE_FAN, 4);
    blueBatch.CopyVertexData3f(vBlock3);
    blueBatch.End();
    
    
    GLfloat vBlock4[] = { 0.25f, -0.75f, 0.0f,
        0.75f, -0.75f, 0.0f,
        0.75f, -0.25f, 0.0f,
        0.25f, -0.25f, 0.0f};
    
    blackBatch.Begin(GL_TRIANGLE_FAN, 4);
    blackBatch.CopyVertexData3f(vBlock4);
    blackBatch.End();
}
