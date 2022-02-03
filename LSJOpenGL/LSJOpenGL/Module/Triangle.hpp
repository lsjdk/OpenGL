//
//  Triangle.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/2.
//

#ifndef Triangle_hpp
#define Triangle_hpp
#include "ModuleSuperclass.hpp"

#include <stdio.h>

class Triangle: public ModuleSuperclass
{
public:
    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulsetupRC() override;
};

#endif /* Triangle_hpp */
