//
//  Triangle.hpp
//  LSJOpenGL
//
//  Created by 李世举 on 2022/2/2.
//

#ifndef Triangle_hpp
#define Triangle_hpp

#include <stdio.h>
#include "ModuleSuperclass.hpp"
//三角形
class Triangle: public ModuleSuperclass
{
public:
    void modulChangeSize(int w,int h) override;
    void modulRenderScene() override;
    void modulSpecialKeys(int key, int x, int y) override;
    void modulSetupRC() override;
};

#endif /* Triangle_hpp */
