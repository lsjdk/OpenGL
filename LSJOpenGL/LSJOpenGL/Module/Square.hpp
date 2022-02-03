//
//  Square.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/3.
//

#ifndef Square_hpp
#define Square_hpp

#include <stdio.h>

#include "ModuleSuperclass.hpp"

class Square: public ModuleSuperclass
{
public:
    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulsetupRC() override;
};

#endif /* Square_hpp */
