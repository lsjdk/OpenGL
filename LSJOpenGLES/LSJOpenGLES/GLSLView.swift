//
//  GLSLView.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/10.
//

import UIKit
import OpenGLES

class GLSLView: UIView {

    var myEagLayer: CAEAGLLayer?
    var myContext: EAGLContext?
    
    var myColorRenderBuffer: GLuint = 0
    var myColorFrameBuffer: GLuint = 0
    var myPrograme: GLuint = 0
    
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //1.设置图层
        self.setupLayer()
        //2.设置上下文
        self.setupContext()
        //3.清空缓存区
        self.deleteRenderAndFrameBuffer()
        //4.设置RenderBuffer
        self.setupRenderBuffer()
        //5.设置FrameBuffer
        self.setupFrameBuffer()
        //6.开始绘制
        self.renderLayer()
    }

}
//MARK: 6.开始绘制
extension GLSLView {
    func renderLayer() {
        //设置清屏颜色
        glClearColor(1.0, 1.0, 0.0, 1.0)
        //清除屏幕
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        //1.设置视口大小
        let scale = UIScreen.main.scale;
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
        
        //2.读取顶点着色器、片元着色器
        
        guard let vertFile = Bundle.main.path(forResource: "GLSLVertex", ofType: "vsh"), let fragFile = Bundle.main.path(forResource: "GLSLFragment", ofType: "fsh") else {
            return
        }
        
        //3.加载shader
        self.myPrograme = self.loadShaers(vertexPath: vertFile, fragmentPath: fragFile)
        
        //4.链接
        glLinkProgram(self.myPrograme)
        
        //获取链接状态
        var linkStatus: GLint = 0
        glGetProgramiv(self.myPrograme, GLenum(GL_LINK_STATUS), &linkStatus)
        
        if linkStatus == GL_FALSE {
//            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
//            glGetProgramiv(self.myPrograme, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(self.myPrograme, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            exit(1)
        }
        print("-=-Program Link Success!=-=-=")
        //5.使用program
        glUseProgram(self.myPrograme)
        
        //6.设置顶点、纹理坐标
        //前3个是顶点坐标，后2个是纹理坐标
        let attrArr: [GLfloat] = [
            0.5, -0.5, 0,     1.0, 0.0,
            -0.5, 0.5, 0,     0.0, 1.0,
            -0.5, -0.5, 0,     0.0, 0.0,
            
            0.5, 0.5, 0,     1.0, 1.0,
            -0.5, 0.5, 0,     0.0, 1.0,
            0.5, -0.5, 0,     1.0, 0.0
        ]
        /*
         1.解决渲染图片倒置问题：
         GLfloat attrArr[] =
         {
         0.5f, -0.5f, 0.0f,        1.0f, 1.0f, //右下
         -0.5f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
         -0.5f, -0.5f, 0.0f,       0.0f, 1.0f, // 左下
         0.5f, 0.5f, 0.0f,         1.0f, 0.0f, // 右上
         -0.5f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
         0.5f, -0.5f, 0.0f,        1.0f, 1.0f, // 右下
         };
         */
        //MARK: -----处理顶点数据--------
        //顶点缓存区
        var attrBuffer: GLuint = 0
        //申请一个缓存区标识符
        glGenBuffers(1, &attrBuffer)
        //将attrBuffer绑定到GL_ARRAY_BUFFER标识符上
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), attrBuffer)
        //把顶点数据从CPU内存复制到GPU上
        glBufferData(GLenum(GL_ARRAY_BUFFER), attrArr.count * MemoryLayout<GLfloat>.size, attrArr, GLenum(GL_DYNAMIC_DRAW))
        //将顶点数据通过myPrograme中的传递到顶点着色程序的position
        //1.glGetAttribLocation,用来获取vertex attribute的入口的.2.告诉OpenGL ES,通过glEnableVertexAttribArray，3.最后数据是通过glVertexAttribPointer传递过去的。
        //注意：第二参数字符串必须和shaderv.vsh中的输入变量：position保持一致
        let position: GLuint = GLuint(glGetAttribLocation(self.myPrograme, "position"))
        //2.设置合适的格式从buffer里面读取数据
        glEnableVertexAttribArray(position)
        //3.设置读取方式
        //参数1：index,顶点数据的索引
        //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
        //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
        //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
        //参数5：stride,连续顶点属性之间的偏移量，默认为0；
        //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
        glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 5 * Int32(MemoryLayout<GLfloat>.size), UnsafeRawPointer(bitPattern: 0))
        
        //MARK: ----处理纹理数据-------
        
        //1.glGetAttribLocation,用来获取vertex attribute的入口的.
        //注意：第二参数字符串必须和shaderv.vsh中的输入变量：textCoordinate保持一致
        let textCoor: GLuint = GLuint(glGetAttribLocation(self.myPrograme, "textCoordinate"))
        
        //2.设置合适的格式从buffer里面读取数据
        glEnableVertexAttribArray(textCoor)
        
        //3.设置读取方式
        //参数1：index,顶点数据的索引
        //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
        //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
        //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
        //参数5：stride,连续顶点属性之间的偏移量，默认为0；
        //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
        glVertexAttribPointer(textCoor, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 5 * Int32(MemoryLayout<GLfloat>.size), UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.size))
        //加载纹理
        self.setupTexture(fileName: "timg-3")
        
        //注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
        /*
         一个一致变量在一个图元的绘制过程中是不会改变的，所以其值不能在glBegin/glEnd中设置。一致变量适合描述在一个图元中、一帧中甚至一个场景中都不变的值。一致变量在顶点shader和片断shader中都是只读的。首先你需要获得变量在内存中的位置，这个信息只有在连接程序之后才可获得
         */
        //rotate等于shaderv.vsh中的uniform属性，rotateMatrix
        let rotate = glGetUniformLocation(self.myPrograme, "rotateMatrix")
        
        //获取渲染的弧度
        let radians: Float = 10 * Float.pi / 180
        //求得弧度对于的sin\cos值
        let s = sin(radians)
        let c = cos(radians)
        
        //z轴旋转矩阵 参考3D数学第二节课的围绕z轴渲染矩阵公式
        //为什么和公司不一样？因为在3D课程中用的是横向量，在OpenGL ES用的是列向量
        var zRotation = [
            c, -s, 0, 0,
            s, c, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
        
        //设置旋转矩阵
        glUniformMatrix4fv(rotate, 1, GLboolean(GL_FALSE), &zRotation)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        self.myContext?.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
    
    //MARK: 设置纹理
    func setupTexture(fileName: String) {
        //1、获取图片的CGImageRef
        //判断图片是否获取成功
        guard let cgimage = UIImage.init(named: fileName)?.cgImage else {
            print("Failed to load image:\(fileName)")
            return
        }
        //2、读取图片的大小，宽和高
        let width = cgimage.width
        let height = cgimage.height
        //3.获取图片字节数 宽*高*4（RGBA）
        var spriteData = [GLubyte](repeating: 0, count: width * height * 4 * MemoryLayout<GLubyte>.size)
        
        //4.创建上下文
        /*
         参数1：data,指向要渲染的绘制图像的内存地址
         参数2：width,bitmap的宽度，单位为像素
         参数3：height,bitmap的高度，单位为像素
         参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
         参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
         参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
         */
        let context = CGContext.init(data: &spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: cgimage.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
        
        //5、在CGContextRef上绘图
        /*
         CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
         CGContextDrawImage
         参数1：绘图上下文
         参数2：rect坐标
         参数3：绘制的图片
         */
        
        //使用默认方式绘制，发现图片是倒的。
        context?.draw(cgimage, in: rect)
        
        /*
         解决图片倒置的方法(2):
         CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
         CGContextTranslateCTM(spriteContext, 0, rect.size.height);
         CGContextScaleCTM(spriteContext, 1.0, -1.0);
         CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
         CGContextDrawImage(spriteContext, rect, spriteImage);
         */
        
        //5、绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        //设置纹理属性
        /*
         参数1：纹理维度
         参数2：线性过滤、为s,t坐标设置模式
         参数3：wrapMode,环绕模式
         */
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        let fw: GLsizei = GLsizei(width)
        let fh: GLsizei = GLsizei(height)
        
        //载入纹理2D数据
        /*
         参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
         参数2：加载的层次，一般设置为0
         参数3：纹理的颜色值GL_RGBA
         参数4：宽
         参数5：高
         参数6：border，边界宽度
         参数7：format
         参数8：type
         参数9：纹理数据
         */
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, fw, fh, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &spriteData)
        
        //绑定纹理
        /*
         参数1：纹理维度
         参数2：纹理ID,因为只有一个纹理，给0就可以了。
         */
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    //MARK: 加载shader
    func loadShaers(vertexPath: String, fragmentPath: String) -> GLuint {
        //定义2个临时着色器对象
        
        //编译顶点着色程序、片元着色器程序
        let vertexShader: GLuint = self.compile(type: GLenum(GL_VERTEX_SHADER), file: vertexPath)
        let fragmentShader: GLuint = self.compile(type: GLenum(GL_FRAGMENT_SHADER), file: fragmentPath)
        //创建program
        let program = glCreateProgram()
        //创建最终的程序
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        //释放不需要的shader
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        return program
    }
    
    //MARK: 链接shader
    
    /// 链接shader
    /// - Parameters:
    ///   - type: 编译的类型，GL_VERTEX_SHADER（顶点）、GL_FRAGMENT_SHADER(片元)
    ///   - file: 文件路径
    /// - Returns: 编译顶点着色程序、片元着色器程序
    func compile(type: GLenum, file: String) -> GLuint {
        
        // swift在编译的时候，需要转换数据类型.
        // 我们先分解这部分
//        let shaderString = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
//        let shaderHandle = glCreateShader(shaderType)
//        var shaderStringLength : GLint = GLint(Int32(shaderString.length))
//        var shaderCString = shaderString.utf8String! as UnsafePointer<GLchar>?
//        var shaderStringLength : GLint = GLint(Int32(shaderString.length))
//        var shaderCString = shaderString.utf8String! as UnsafePointer<GLchar>?
//        glShaderSource(
//            shaderHandle,
//            GLsizei(1),
//            &shaderCString,
//            &shaderStringLength)
        
        //创建一个shader（根据type类型）
        let shader = glCreateShader(type)
        
        //str.cStringUsingEncoding(NSUTF8StringEncoding)!
        
        //读取文件路径字符串
        let shaderString = try? try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue)
        
        let shaderStringUTF8 = shaderString!.cString(using: String.defaultCStringEncoding.rawValue)

        //UnsafePointer<UnsafePointer<GLchar>?>
        var glsource = UnsafePointer(shaderStringUTF8)
        
        
        var shaderStringLength: GLint = GLint((shaderString?.length)!)
        
        
        //将顶点着色器源码附加到着色器对象上。
        //参数1：shader,要编译的着色器对象 *shader
        //参数2：numOfStrings,传递的源码字符串数量 1个
        //参数3：strings,着色器程序的源码（真正的着色器程序源码）
        //参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
        glShaderSource(shader, 1, &glsource, &shaderStringLength)
        //把着色器源代码编译成目标代码
        glCompileShader(shader)
        
        return shader
        
    }
}
extension GLSLView {
    //MARK: 5.设置FrameBuffer
    func setupFrameBuffer() {
        //1.定义一个缓存区
        var buffer: GLuint = 0
        //2.申请一个缓存区标志
        glGenFramebuffers(1, &buffer)
        self.myColorFrameBuffer = buffer
        //4.将标识符绑定到GL_FRAMEBUFFER
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.myColorFrameBuffer)
        
        //生成空间之后，则需要将renderbuffer跟framebuffer进行绑定，调用glFramebufferRenderbuffer函数进行绑定，后面的绘制才能起作用
        //5.将_myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到GL_COLOR_ATTACHMENT0上。
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.myColorFrameBuffer)
        
        //接下来，可以调用OpenGL ES进行绘制处理，最后则需要在EGALContext的OC方法进行最终的渲染绘制。这里渲染的color buffer,这个方法会将buffer渲染到CALayer上。- (BOOL)presentRenderbuffer:(NSUInteger)target;
    }
    //MARK: 4.设置RenderBuffer
    func setupRenderBuffer() {
        //1.定义一个缓存区
        var buffer: GLuint = 0
        //2.申请一个缓存区标志
        glGenBuffers(1, &buffer)
        self.myColorRenderBuffer = buffer
        //4.将标识符绑定到GL_RENDERBUFFER
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.myColorRenderBuffer)
        //frame buffer仅仅是管理者，不需要分配空间；render buffer的存储空间的分配，对于不同的render buffer，使用不同的API进行分配，而只有分配空间的时候，render buffer句柄才确定其类型
        
        //myColorRenderBuffer渲染缓存区分配存储空间
        self.myContext?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.myEagLayer)
    }
    //MARK: 3.清空缓存区
    func deleteRenderAndFrameBuffer() {
        //1.导入框架#import <OpenGLES/ES2/gl.h>
        /*
         2.创建2个帧缓存区，渲染缓存区，帧缓存区
         @property (nonatomic , assign) GLuint myColorRenderBuffer;
         @property (nonatomic , assign) GLuint myColorFrameBuffer;
         
         A.离屏渲染，详细解释见课件
         
         B.buffer的分类,详细见课件
         
         buffer分为frame buffer 和 render buffer2个大类。其中frame buffer 相当于render buffer的管理者。frame buffer object即称FBO，常用于离屏渲染缓存等。render buffer则又可分为3类。colorBuffer、depthBuffer、stencilBuffer。
         //绑定buffer标识符
         glGenRenderbuffers(<#GLsizei n#>, <#GLuint *renderbuffers#>)
         glGenFramebuffers(<#GLsizei n#>, <#GLuint *framebuffers#>)
         //绑定空间
         glBindRenderbuffer(<#GLenum target#>, <#GLuint renderbuffer#>)
         glBindFramebuffer(<#GLenum target#>, <#GLuint framebuffer#>)
         
         
         */
        glDeleteBuffers(1, &self.myColorRenderBuffer)
        self.myColorRenderBuffer = 0
        
        glDeleteBuffers(1, &self.myColorFrameBuffer)
        self.myColorFrameBuffer = 0
    }
    //MARK: 2.设置上下文
    func setupContext() {
        //1.指定OpenGL ES 渲染API版本
        let api: EAGLRenderingAPI = .openGLES3
        //2.创建图形上下文
        let context: EAGLContext? = EAGLContext.init(api: api)
        //3.判断是否创建成功
        if context == nil {
            print("Create context Failed")
            return
        }
        //4.设置图形上下文
        if !EAGLContext.setCurrent(context) {
            print("SetCurrentContext failed")
            return
        }
        //5.将局部context，变成全局的
        self.myContext = context
    }
    //MARK: 1.设置图层
    func setupLayer() {
        //给图层开辟空间
        /*
         重写layerClass，将CCView返回的图层从CALayer替换成CAEAGLLayer
         */
        self.myEagLayer = self.layer as? CAEAGLLayer
        //设置放大倍数
        self.contentScaleFactor = UIScreen.main.scale
        //CALayer 默认是透明的，必须将它设为不透明才能将其可见。
        self.myEagLayer?.isOpaque = true
        //设置描述属性，这里设置不维持渲染内容以及颜色格式为RGBA8
        /*
         kEAGLDrawablePropertyRetainedBacking                          表示绘图表面显示后，是否保留其内容。这个key的值，是一个通过NSNumber包装的bool值。如果是false，则显示内容后不能依赖于相同的内容，ture表示显示后内容不变。一般只有在需要内容保存不变的情况下，才建议设置使用,因为会导致性能降低、内存使用量增减。一般设置为flase.
         
        kEAGLDrawablePropertyColorFormat
             可绘制表面的内部颜色缓存区格式，这个key对应的值是一个NSString指定特定颜色缓存区对象。默认是kEAGLColorFormatRGBA8；
             kEAGLColorFormatRGBA8：32位RGBA的颜色，4*8=32位
             kEAGLColorFormatRGB565：16位RGB的颜色，
             kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。
         
         
         */
        self.myEagLayer?.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,
                                                   kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]
    }
}
