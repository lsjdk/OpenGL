//
//  main.cpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/2.
//

#include <stdio.h>
#include "Triangle.hpp"
#include "ModuleSuperclass.hpp"
#include "Square.hpp"
#include "Primitive.hpp"
#include "FaceCulling.hpp"
#include "AntiAliasing.hpp"

int moduleSuperShow(int argc, char *argv[]);

int main(int argc,char* argv[])
{
    moduleSuperShow(argc, argv);
    return 0;
}

AntiAliasing modul;


//
////定义一个，着色管理器
//GLShaderManager shaderManager;
//
////简单的批次容器，是GLTools的一个简单的容器类。
//GLBatch triangleBatch;
//
//

//右键菜单栏选项
void ProcessMenu(int value) {
    modul.modulProcessMenu(value);
    glutPostRedisplay();
}

//根据空格次数。切换不同的“窗口名称”
void KeyPressFunc(unsigned char key, int x, int y) {
    modul.modulKeyPressFunc(key, x, y);
    glutPostRedisplay();
}

///*
// 在窗口大小改变时，接收新的宽度&高度。
// */
void changeSize(int w,int h) {
    //防止窗口高度为0
    if (h == 0)  h = 1;
    /*
     x,y 参数代表窗口中视图的左下角坐标，而宽度、高度是像素为表示，通常x,y 都是为0
     */
    
    glViewport(0, 0, w, h);
    modul.modulChangeSize(w, h);
}
//
void SpecialKeys(int key, int x, int y) {
    modul.modulSpecialKeys(key, x, y);
    glutPostRedisplay();
}
//
void RenderScene(void) {
    
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
    
    modul.modulRenderScene();
    
    glutSwapBuffers();
    
}
//
void setupRC() {
    
    modul.modulSetupRC();
//    //设置清屏颜色（背景颜色）
//    glClearColor(0.98f, 0.40f, 0.7f, 1);
    
}
//
int moduleSuperShow(int argc, char *argv[]) {
    //设置当前工作目录，针对MAC OS X
    /*
     `GLTools`函数`glSetWorkingDrectory`用来设置当前工作目录。实际上在Windows中是不必要的，因为工作目录默认就是与程序可执行执行程序相同的目录。但是在Mac OS X中，这个程序将当前工作文件夹改为应用程序捆绑包中的`/Resource`文件夹。`GLUT`的优先设定自动进行了这个中设置，但是这样中方法更加安全。
     */
    gltSetWorkingDirectory(argv[0]);
    
    
    //初始化GLUT库,这个函数只是传说命令参数并且初始化glut库
    glutInit(&argc, argv);
    
    /*
     初始化双缓冲窗口，其中标志GLUT_DOUBLE、GLUT_RGBA、GLUT_DEPTH、GLUT_STENCIL分别指
     双缓冲窗口、RGBA颜色模式、深度测试、模板缓冲区
     
     --GLUT_DOUBLE`：双缓存窗口，是指绘图命令实际上是离屏缓存区执行的，然后迅速转换成窗口视图，这种方式，经常用来生成动画效果；
     --GLUT_DEPTH`：标志将一个深度缓存区分配为显示的一部分，因此我们能够执行深度测试；
     --GLUT_STENCIL`：确保我们也会有一个可用的模板缓存区。
     深度、模板测试后面会细致讲到
     */
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH|GLUT_STENCIL|GLUT_MULTISAMPLE);
    
    //GLUT窗口大小、窗口标题
    glutInitWindowSize(800, 600);
    glutCreateWindow("Triangle");
    
    /*
     GLUT 内部运行一个本地消息循环，拦截适当的消息。然后调用我们不同时间注册的回调函数。我们一共注册2个回调函数：
     1）为窗口改变大小而设置的一个回调函数
     2）包含OpenGL 渲染的回调函数
     */
    //注册重塑函数
    glutReshapeFunc(changeSize);
//    //注册显示函数
    glutDisplayFunc(RenderScene);
    //注册特殊函数
    glutSpecialFunc(SpecialKeys);
    //点击空格时，调用的函数
    glutKeyboardFunc(KeyPressFunc);
    
    //设置右键弹出菜单栏
    glutCreateMenu(ProcessMenu);
//    glutAddMenuEntry("Toggle depth test",1);
//    glutAddMenuEntry("Toggle cull backface",2);
//    glutAddMenuEntry("Set Fill Mode", 3);
//    glutAddMenuEntry("Set Line Mode", 4);
//    glutAddMenuEntry("Set Point Mode", 5);
    
    glutAddMenuEntry("Antialiased Rendering",1);
    glutAddMenuEntry("Normal Rendering",2);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
    
    glutAttachMenu(GLUT_RIGHT_BUTTON);
    
    /*
     初始化一个GLEW库,确保OpenGL API对程序完全可用。
     在试图做任何渲染之前，要检查确定驱动程序的初始化过程中没有任何问题
     */
    GLenum status = glewInit();
    if (GLEW_OK != status) {
        printf("GLEW Error:%s\n",glewGetErrorString(status));
        return 1;
    }
    
    //设置我们的渲染环境
    setupRC();
    
    glutMainLoop();
    
    return  0;
    
}
