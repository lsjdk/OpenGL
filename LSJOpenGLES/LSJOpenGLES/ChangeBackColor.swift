//
//  ChangeBackColor.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/9.
//

import UIKit
import GLKit

class ChangeBackColor: GLKViewController {

//    var context: EAGLContext?
//    var kview: GLKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpConfig()
        
    }
    func setUpConfig() {
        
        //创建一个OpenGL ES上下文并将其分配给从storyboard加载的视图
        //注意：这里需要把stroyBoard记得添加为GLKView
        
        let kview = self.view as! GLKView
        //context
        /*
         
         //EAGLContent是苹果在ios平台下实现的opengles渲染层，用于渲染结果在目标surface上的更新
         kEAGLRenderingAPIOpenGLES1 ->OpenGL ES 1.0，固定管线
         kEAGLRenderingAPIOpenGLES2 ->OpenGL ES 2.0
         kEAGLRenderingAPIOpenGLES3 ->OpenGL ES 3.0
         
         */
        
        //新建OpenGL ES上下文
        let context = EAGLContext.init(api: .openGLES3)
        kview.context = context!
        EAGLContext.setCurrent(kview.context)

        //配置视图创建的渲染缓冲区
        /*
         OpenGL ES 有一个缓存区，它用以存储将在屏幕中显示的颜色。你可以使用其属性来设置缓冲区中的每个
         像素的颜色格式。
         默认：GLKViewDrawableColorFormatRGBA8888，即缓存区的每个像素的最小组成部分（RGBA）使用
         8个bit，（所以每个像素4个字节，4*8个bit）。
         GLKViewDrawableColorFormatRGB565,如果你的APP允许更小范围的颜色，即可设置这个。会让你的
         APP消耗更小的资源（内存和处理时间）
         */
        
        
        kview.drawableColorFormat = .RGBA8888
        
        /*
         OpenGL ES 另一个缓存区，深度缓冲区。帮助我们确保可以更接近观察者的对象显示在远一些的对象前面。
         （离观察者近一些的对象会挡住在它后面的对象）
         默认：OpenGL把接近观察者的对象的所有像素存储到深度缓冲区，当开始绘制一个像素时，它（OpenGL）
         首先检查深度缓冲区，看是否已经绘制了更接近观察者的什么东西，如果是则忽略它（要绘制的像素，
         就是说，在绘制一个像素之前，看看前面有没有挡着它的东西，如果有那就不用绘制了）。否则，
         把它增加到深度缓冲区和颜色缓冲区。
         缺省值是GLKViewDrawableDepthFormatNone，意味着完全没有深度缓冲区。
         但是如果你要使用这个属性（一般用于3D游戏），你应该选择GLKViewDrawableDepthFormat16
         或GLKViewDrawableDepthFormat24。这里的差别是使用GLKViewDrawableDepthFormat16
         将消耗更少的资源，但是当对象非常接近彼此时，你可能存在渲染问题（）
         */
        
        kview.drawableDepthFormat = .format24
        
        //启用多重采样
        /*
         这是你可以设置的最后一个可选缓冲区，对应的GLKView属性是multisampling。
         如果你曾经尝试过使用OpenGL画线并关注过"锯齿壮线"，multisampling就可以帮助你处理
         以前对于每个像素，都会调用一次fragment shader（片段着色器），
         drawableMultisample基本上替代了这个工作，它将一个像素分成更小的单元，
         并在更细微的层面上多次调用fragment shader。之后它将返回的颜色合并，
         生成更光滑的几何边缘效果。
         要小心此操作，因为它需要占用你的app的更多的处理时间和内存。
         缺省值是GLKViewDrawableMultisampleNone，但是你可以通过设置其值GLKViewDrawableMultisample4X为来使能它
         */
        kview.drawableMultisample = .multisample4X
//
        glEnable(GLenum(GL_DEPTH_TEST)); //开启深度测试，就是让离你近的物体可以遮挡离你远的物体。
        
        glClearColor(1, 0.0, 0.0, 1)  //设置surface的清除颜色，也就是渲染到屏幕上的背景色。
    }
}

extension ChangeBackColor {
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        //清除surface内容，恢复至初始状态
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    }
}
