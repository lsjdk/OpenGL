//
//  PhotoViewController.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/10.
//

import UIKit
import GLKit

class PhotoViewController: ChangeBackColor {

    var mEffect: GLKBaseEffect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uploadVertexArray()
        self.uploadTexture()
        
    }
    func uploadTexture() {
        //第一步，获取纹理图片保存路径
        let filePath = Bundle.main.path(forResource: "cTest", ofType: "jpg")
        //GLKTextureLoaderOriginBottomLeft,纹理坐标是相反的
        let options = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: 1)]
        
        
        let textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: filePath!, options: options)
        //着色器
        self.mEffect = GLKBaseEffect.init()
        //第一个纹理属性
        mEffect?.texture2d0.enabled = GLboolean(GL_TRUE)
        //纹理的名字
        mEffect?.texture2d0.name = (textureInfo?.name)!
        
    }
    func uploadVertexArray() {
        //第一步：设置顶点数组
        //OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
        //顶点数据，前3个是顶点坐标x,y,z；后面2个是纹理坐标。
        //纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角
        //2个三角形构成
        let vertexData: [GLfloat] = [
            0.5, -0.5, 0.0,   1.0, 0.0,//右下
            0.5, 0.5, 0.0,    1.0, 1.0,//右上
            -0.5, 0.5, 0.0,   0.0, 1.0,//左上
            
            0.5, -0.5, 0.0,   1.0, 0.0,//右下
            -0.5, 0.5, 0.0,   0.0, 1.0,//左上
            -0.5, -0.5, 0.0,  0.0, 0.0//左下
        ]
        
        //开启顶点缓冲区
        //顶点缓存区
        var buffer: GLuint = 0;
        //申请一个缓存区标识符
        glGenBuffers(1, &buffer)
        //glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer)
        
        //glBufferData把顶点数据从cpu内存复制到gpu内存
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.count * MemoryLayout<GLfloat>.size , vertexData, GLenum(GL_STATIC_DRAW))
        
        //第三步：设置合适的格式从buffer里面读取数据）
        /*
         默认情况下，出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的，意味着数据在着色器端是不可见的，哪怕数据已经上传到GPU，由glEnableVertexAttribArray启用指定属性，才可在顶点着色器中访问逐顶点的属性数据。glVertexAttribPointer或VBO只是建立CPU和GPU之间的逻辑连接，从而实现了CPU数据上传至GPU。但是，数据在GPU端是否可见，即，着色器能否读取到数据，由是否启用了对应的属性决定，这就是glEnableVertexAttribArray的功能，允许顶点着色器读取GPU（服务器端）数据。
         */
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        
        //glVertexAttribPointer 使用来上传顶点数据到GPU的方法（设置合适的格式从buffer里面读取数据）
        // index: 指定要修改的顶点属性的索引值
        // size : 指定每个顶点属性的组件数量。必须为1、2、3或者4。初始值为4。（如position是由3个（x,y,z）组成，而颜色是4个（r,g,b,a））
        // type : 指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT。
        // normalized : 指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）
        // stride : 指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0
        // ptr    : 指定一个指针，指向数组中第一个顶点属性的第一个组件。初始值为0 这个值受到VBO的影响
        
        /*
         VBO,顶点缓存对象
         在不使用VBO的情况下：事情是这样的，ptr就是一个指针，指向的是需要上传到顶点数据指针。通常是数组名的偏移量。
         
         在使用VBO的情况下：首先要glBindBuffer，以后ptr指向的就不是具体的数据了。因为数据已经缓存在缓冲区了。这里的ptr指向的是缓冲区数据的偏移量。这里的偏移量是整型，但是需要强制转换为const GLvoid *类型传入。注意的是，这里的偏移的意思是数据个数总宽度数值。
         
         比如说：这里存放的数据前面有3个float类型数据，那么这里的偏移就是，3*sizeof(float).
         
         最后解释一下，glVertexAttribPointer的工作原理：
         首先，通过index得到着色器对应的变量openGL会把数据复制给着色器的变量。
         以后，通过size和type知道当前数据什么类型，有几个。openGL会映射到float，vec2, vec3 等等。
         由于每次上传的顶点数据不止一个，可能是一次4，5，6顶点数据。那么通过stride就是在数组中间隔多少byte字节拿到下个顶点此类型数据。
         最后，通过ptr的指针在迭代中获得所有数据。
         那么，最最后openGL如何知道ptr指向的数组有多长，读取几次呢。是的，openGL不知道。所以在调用绘制的时候，需要传入一个count数值，就是告诉openGL绘制的时候迭代几次glVertexAttribPointer调用。
         */
        //(GLfloat *)NULL + 0 指针，指向数组首地址
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 5, UnsafeRawPointer(bitPattern: 0))
        
        
        //纹理
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        //(GLfloat *)NULL + 3,指向到纹理数据
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 5, UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.size))
        
    }
    
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        super.glkView(view, drawIn: rect)
        
        //启动着色器
        self.mEffect?.prepareToDraw()
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
    }
}
