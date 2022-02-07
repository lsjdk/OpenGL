//
//  FaceCulling.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/7.
//

#ifndef FaceCulling_hpp
#define FaceCulling_hpp

#include <stdio.h>

#include "ModuleSuperclass.hpp"
//移动的四边形
class FaceCulling: public ModuleSuperclass
{
public:
    
    GLFrame             viewFrame;
    
    GLTriangleBatch     torusBatch;
    
    //正背面剔除开启、关闭
    int iCull = 0;
    //深度测试开启、关闭
    int iDepth = 0;

    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulSetupRC() override;
    void modulKeyPressFunc(unsigned char key, int x, int y) override;
    void modulProcessMenu(int value) override;
};

#endif /* FaceCulling_hpp */
