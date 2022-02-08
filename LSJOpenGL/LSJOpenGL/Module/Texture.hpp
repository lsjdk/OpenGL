//
//  Texture.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/8.
//

#ifndef Texture_hpp
#define Texture_hpp

#include <stdio.h>
#include "ModuleSuperclass.hpp"

//纹理
class Texture: public ModuleSuperclass
{
public:
    GLBatch pyramidBatch;
    
    //纹理变量，一般使用无符号整型
    GLuint              textureID;

    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulSetupRC() override;
    void modulKeyPressFunc(unsigned char key, int x, int y) override;
    void modulProcessMenu(int value) override;
    void modulShutdownRC() override;
};

#endif /* Texture_hpp */
