//
//  ModuleSuperclass.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/2.
//

#ifndef ModuleSuperclass_hpp
#define ModuleSuperclass_hpp

#include <stdio.h>

#include "GLShaderManager.h"
/*
 `#include<GLShaderManager.h>` 移入了GLTool 着色器管理器（shader Mananger）类。没有着色器，我们就不能在OpenGL（核心框架）进行着色。着色器管理器不仅允许我们创建并管理着色器，还提供一组“存储着色器”，他们能够进行一些初步䄦基本的渲染操作。
 */

#include "GLTools.h"
/*
 `#include<GLTools.h>`  GLTool.h头文件包含了大部分GLTool中类似C语言的独立函数
 */


#include <GLUT/GLUT.h>

#include "GLMatrixStack.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLBatch.h"
#include "GLGeometryTransform.h"

//GLShaderManager        shaderManager;
//GLMatrixStack        modelViewMatrix;
//GLMatrixStack        projectionMatrix;
//GLFrame                cameraFrame;
//GLFrame             objectFrame;
////投影矩阵
//GLFrustum            viewFrustum;


/*
 在Mac 系统下，`#include<glut/glut.h>`
 在Windows 和 Linux上，我们使用freeglut的静态库版本并且需要添加一个宏
 */
class ModuleSuperclass
{
    public:
    // 各种需要的类
    //定义一个，着色管理器
    GLShaderManager shaderManager;
    
    //简单的批次容器，是GLTools的一个简单的容器类。
    GLBatch triangleBatch;
    
    
    GLMatrixStack        modelViewMatrix;
    GLMatrixStack        projectionMatrix;
    GLFrame                cameraFrame;
    GLFrame             objectFrame;
    //投影矩阵
    GLFrustum            viewFrustum;
    
    
    //几何变换的管道
    GLGeometryTransform    transformPipeline;
    M3DMatrix44f        shadowMatrix;
    
    virtual void modulChangeSize(int w,int h);
    virtual void modulRenderScene();
    virtual void modulSpecialKeys(int key, int x, int y);
    virtual void modulSetupRC();
    virtual void modulKeyPressFunc(unsigned char key, int x, int y);
};




#endif /* ModuleSuperclass_hpp */
