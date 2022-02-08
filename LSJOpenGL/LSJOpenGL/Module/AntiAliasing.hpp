//
//  AntiAliasing.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/7.
//

#ifndef AntiAliasing_hpp
#define AntiAliasing_hpp

#include <stdio.h>
#include "ModuleSuperclass.hpp"
//抗锯齿、多重采样
class AntiAliasing: public ModuleSuperclass
{
public:
    
    GLFrustum viewFrustum;
    GLBatch smallStarBatch;
    GLBatch mediumStarBatch;
    GLBatch largeStarBatch;
    GLBatch mountainRangeBatch;
    GLBatch moonBatch;

    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulSetupRC() override;
    void modulKeyPressFunc(unsigned char key, int x, int y) override;
    void modulProcessMenu(int value) override;
};

#endif /* AntiAliasing_hpp */
