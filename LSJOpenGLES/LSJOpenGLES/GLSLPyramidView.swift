//
//  GLSLPyramidView.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/12.
//

import UIKit
import Accelerate
import GLKit


class GLSLPyramidView: UIView {

    var mylayer: CAEAGLLayer?
    var myContext: EAGLContext?
    
    var myRenderBuffer: GLuint = 0
    var myFrameBuffer: GLuint = 0
    
    var myPrograme: GLuint = 0
    
    var myVertices: GLuint = 0
    var myIndex: GLuint = 0
    
    
    var xDegree: Float = 0
    var yDegree: Float = 0
    var zDegree: Float = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //1.设置layer
        self.setUplayer()
        //2.设置context
        self.setUpContext()
        //3.清空缓存区
        self.deleteBuffer()
        //4.设置RenderBuffer
        self.setUpRenderBuffer()
        //5.设置FrameBuffer
        self.setUpFrameBuffer()
        //6.渲染
        self.renderLayer()
    }
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

}
extension GLSLPyramidView {
    func renderLayer() -> Void {
        //1.清理屏幕
        glClearColor(0, 0, 1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))
        
        //2.设置屏幕大小
        let scale = UIScreen.main.scale
        
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
        
        //3.获取顶点/片元着色器文件
        
        guard let vertexFile = Bundle.main.path(forResource: "GLSLPyramidShaderV", ofType: "glsl"), let fragmentFile = Bundle.main.path(forResource: "GLSLPyramidShaderF", ofType: "glsl") else {
            return
        }
        
        //4. 获得着色器
        
        self.myPrograme = GLSLManager.loadProgram(vertexPath: vertexFile, fragmentPath: fragmentFile)
        if self.myPrograme == 0 {
            print("-=-Program Link Failed!=-=-=")
            return
        }
        print("-=-Program Link Success!=-=-=")
        
        glUseProgram(self.myPrograme)
        
        let indices: [GLuint] = [
            0, 3, 2,
            0, 1, 3,
            0, 2, 4,
            0, 4, 1,
            2, 3, 4,
            1, 4, 3
        ]
        
        if self.myVertices == 0 {
            glGenBuffers(1, &self.myVertices)
        }
        
        let attrArr: [GLfloat] = [
            -0.5, 0.5, 0.0,      1.0, 0.0, 1.0, //左上
            0.5, 0.5, 0.0,       1.0, 0.0, 1.0, //右上
            -0.5, -0.5, 0.0,     1.0, 1.0, 1.0, //左下
            0.5, -0.5, 0.0,      1.0, 1.0, 1.0, //右下
            0.0, 0.0, 1.0,       0.0, 1.0, 0.0, //顶点
        ]
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.myVertices)
        
        glBufferData(GLenum(GL_ARRAY_BUFFER), attrArr.count * MemoryLayout<GLfloat>.size, attrArr, GLenum(GL_DYNAMIC_DRAW))
        
//        var ebo: GLuint = 0
        //缓存顶点
//        glGenBuffers(1, &self.myIndex)
//        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.myIndex)
//        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLuint>.size, indices, GLenum(GL_STATIC_DRAW))
        
        let position: GLuint = GLuint(glGetAttribLocation(self.myPrograme, "position"))

        glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 6, UnsafeRawPointer(bitPattern: 0))

        glEnableVertexAttribArray(position)
        
        let positionColor: GLuint = GLuint(glGetAttribLocation(self.myPrograme, "positionColor"))
        
        glVertexAttribPointer(positionColor, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 6, UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.size))
        
        glEnableVertexAttribArray(positionColor)
        
        
        let projectionMatrix: GLint = GLint(glGetUniformLocation(self.myPrograme, "projectionMatrix"))
        let modelViewMatrix: GLint = GLint(glGetUniformLocation(self.myPrograme, "modelViewMatrix"))
        var _projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
        let aspect = self.frame.size.width / self.frame.size.height
        _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(30), Float(aspect), 5, 20)
        let countP = MemoryLayout.size(ofValue: _projectionMatrix.m) / MemoryLayout.size(ofValue: _projectionMatrix.m.0)

        withUnsafePointer(to: &_projectionMatrix.m) { pointer in
            pointer.withMemoryRebound(to: GLfloat.self, capacity: countP) { pon in
                glUniformMatrix4fv(projectionMatrix, GLsizei(1), GLboolean(GL_FALSE), pon)
            }
        }
        glEnable(GLenum(GL_CULL_FACE))
//
        var _modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity
        _modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10)
        var _rotationMatrix: GLKMatrix4 = GLKMatrix4Identity
        
        _rotationMatrix = GLKMatrix4RotateX(_rotationMatrix, xDegree)
        _rotationMatrix = GLKMatrix4RotateX(_rotationMatrix, yDegree)
        _rotationMatrix = GLKMatrix4RotateX(_rotationMatrix, zDegree)
        
        _modelViewMatrix = GLKMatrix4Multiply(_rotationMatrix, _modelViewMatrix)
        
        let countM = MemoryLayout.size(ofValue: _modelViewMatrix.m) / MemoryLayout.size(ofValue: _modelViewMatrix.m.0)

        withUnsafePointer(to: &_modelViewMatrix) { pointer in
            pointer.withMemoryRebound(to: GLfloat.self, capacity: countM) { pon in
                glUniformMatrix4fv(modelViewMatrix, GLsizei(1), GLboolean(GL_FALSE), pon)
            }
        }
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), indices)
        
        self.myContext?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}
extension GLSLPyramidView {
    
    func setUpFrameBuffer() -> Void {
        var buffer: GLuint = 0
        glGenFramebuffers(1, &buffer)
        self.myFrameBuffer = buffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.myFrameBuffer)
        //生成空间之后，则需要将renderbuffer跟framebuffer进行绑定，调用glFramebufferRenderbuffer函数进行绑定，后面的绘制才能起作用
        //5.将_myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到GL_COLOR_ATTACHMENT0上。
//        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.myColorFrameBuffer)
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.myFrameBuffer)
    }
    
    func setUpRenderBuffer() -> Void {
        var buffer: GLuint = 0
        
        glGenRenderbuffers(1, &buffer)
        self.myRenderBuffer = buffer
        
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.myRenderBuffer)
        self.myContext?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.mylayer)
    }
    
    func deleteBuffer() -> Void {
        
        glDeleteBuffers(0, &self.myRenderBuffer)
        self.myRenderBuffer = 0
        
        glDeleteBuffers(0, &self.myFrameBuffer)
        self.myFrameBuffer = 0
        
    }
    
    func setUpContext() -> Void {
        self.myContext = EAGLContext.init(api: .openGLES3)
        if self.myContext == nil {
            return
        }
        EAGLContext.setCurrent(self.myContext)
    }
    func setUplayer() -> Void {
        self.mylayer = self.layer as? CAEAGLLayer
        self.contentScaleFactor = UIScreen.main.scale
        self.mylayer?.isOpaque = true
        
        self.mylayer?.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,
                                                kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
     ]
    }
}

