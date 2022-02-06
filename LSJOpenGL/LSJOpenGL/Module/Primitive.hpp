//
//  Primitive.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/6.
//

#ifndef Primitive_hpp
#define Primitive_hpp


#include <stdio.h>
#include "ModuleSuperclass.hpp"

//图元
class Primitive: public ModuleSuperclass
{
public:
    
    //容器类（7种不同的图元对应7种容器对象）
    GLBatch                pointBatch;
    GLBatch                lineBatch;
    GLBatch                lineStripBatch;
    GLBatch                lineLoopBatch;
    GLBatch                triangleBatch;
    GLBatch             triangleStripBatch;
    GLBatch             triangleFanBatch;
    
    
    // 跟踪效果步骤
    int nStep = 0;
    
    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulSetupRC() override;
    void modulKeyPressFunc(unsigned char key, int x, int y);
};

#endif /* Primitive_hpp */
