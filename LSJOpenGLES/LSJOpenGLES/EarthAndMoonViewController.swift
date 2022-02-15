//
//  EarthAndMoonViewController.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/14.
//

import UIKit
import GLKit

//月球轨道日数
let SceneDaysPerMoonOrbit: GLfloat = 28.0;

class EarthAndMoonViewController: GLKViewController {

    var myEffect: GLKBaseEffect = GLKBaseEffect.init()
    
    private var modelViewMatrixStack: GLKMatrixStack = (GLKMatrixStackCreate(kCFAllocatorDefault)?.takeRetainedValue())!
    
    private var vertexPositionBuffer: GLuint = 0
    private var vertexNormalBuffer: GLuint = 0
    private var vertextTextureCoordBuffer: GLuint = 0
    
    
    private var earthRotationAngleDegress: GLfloat = 0
    private var moonRotationAngleDegress: GLfloat = 0
    
    
    private var earchTextureInfo: GLKTextureInfo?
    private var moonTextureInfo: GLKTextureInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpLayerAndContext()
        self.configureLight()
        self.configureMatrix()
        
        let colorVector4 = GLKVector4Make(0, 0, 0, 1.0)
        
        glClearColor(colorVector4.r, colorVector4.g, colorVector4.b, colorVector4.a)
        
        self.bufferData()
    }
}
extension EarthAndMoonViewController {
    func bufferData() -> Void {
        
        self.modelViewMatrixStack = (GLKMatrixStackCreate(kCFAllocatorDefault)?.takeRetainedValue())!
        
        //缓存顶点数据
        
        glGenBuffers(1, &vertexPositionBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexPositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sphereVerts.count * MemoryLayout<GLfloat>.size, sphereVerts, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 3, UnsafeRawPointer.init(bitPattern: 0))
        
        glGenBuffers(1, &vertexNormalBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexNormalBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sphereNormals.count * MemoryLayout<GLfloat>.size, sphereNormals, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 3, UnsafeRawPointer.init(bitPattern: 0))
        
        glGenBuffers(1, &vertextTextureCoordBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertextTextureCoordBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sphereTexCoords.count * MemoryLayout<GLfloat>.size, sphereTexCoords, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 2, UnsafeRawPointer.init(bitPattern: 0))
        
        let option1 = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: true)]
        let option2 = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: true)]
        
        guard let earthCGiamge = UIImage.init(named: "Earth512x256.jpg")?.cgImage,
              let moonCGiamge = UIImage.init(named: "Moon256x128.png")?.cgImage else {
            return
        }
        
        guard let earchTextureInfo = try? GLKTextureLoader.texture(with: earthCGiamge, options: option1),
              let moonTextureInfo = try? GLKTextureLoader.texture(with: moonCGiamge, options: option2) else {
            return
        }
        
        self.earchTextureInfo = earchTextureInfo
        self.moonTextureInfo = moonTextureInfo
        
        GLKMatrixStackLoadMatrix4(self.modelViewMatrixStack, self.myEffect.transform.modelviewMatrix)
        
    }
    func configureMatrix() -> Void {
        let aspect: Float = Float(self.view.frame.size.width / self.view.frame.size.height)
        
        self.myEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspect, 1.0 * aspect, -1.0, 1.0, 1.0, 120)
        
        self.myEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0, 0, -10.0)
    }
    func configureLight() -> Void {
        self.myEffect.texture2d0.enabled = GLboolean(GL_TRUE)
        self.myEffect.light0.enabled = GLboolean(GL_TRUE)
        //2.设置漫射光颜色
        self.myEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
        
        
        self.myEffect.light0.position = GLKVector4Make(1.0, 0.0, 0.8, 0.0)
        
        //光的环境部分
        self.myEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0)
        
    }
    func setUpLayerAndContext() -> Void {
        guard let kView = self.view as? GLKView,
              let context = EAGLContext.init(api: .openGLES2),
              EAGLContext.setCurrent(context) else {
            return
        }
        
        kView.context = context
        kView.drawableColorFormat = .RGBA8888
        kView.drawableDepthFormat = .format24
//        kView.drawableMultisample = .multisample4X
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
    }
}
extension EarthAndMoonViewController {
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.3, 0.3, 0.3, 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        self.earthRotationAngleDegress += 360 / 60
        self.moonRotationAngleDegress += (360 / 60 / SceneDaysPerMoonOrbit)
        
        self.drawEarth()
        self.drawMoon()
    }
}

extension EarthAndMoonViewController {
    func drawEarth() -> Void {
        self.myEffect.texture2d0.name = self.earchTextureInfo!.name
        self.myEffect.texture2d0.target = GLKTextureTarget.init(rawValue: (self.earchTextureInfo?.target)!)!
        
        GLKMatrixStackPush(self.modelViewMatrixStack)
        
        GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(earthRotationAngleDegress), 0.0, 1.0, 0.0)
        
        self.myEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack)
        
        self.myEffect.prepareToDraw()
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(sphereNumVerts));
        
        GLKMatrixStackPop(self.modelViewMatrixStack)
        
        self.myEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack)
    }
    func drawMoon() -> Void {
        self.myEffect.texture2d0.name = self.moonTextureInfo!.name
        self.myEffect.texture2d0.target = GLKTextureTarget.init(rawValue: (self.moonTextureInfo?.target)!)!
        
        GLKMatrixStackPush(self.modelViewMatrixStack)
        
        GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(moonRotationAngleDegress), 0.0, 1.0, 0.0)
        
        GLKMatrixStackTranslate(self.modelViewMatrixStack, 0, 0, 2)
        
        GLKMatrixStackScale(self.modelViewMatrixStack, 0.25, 0.25, 0.25)
        
        GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(moonRotationAngleDegress), 0.0, 1.0, 0.0)
        
        self.myEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack)
        
        self.myEffect.prepareToDraw()
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(sphereNumVerts));
        
        GLKMatrixStackPop(self.modelViewMatrixStack)
        
        self.myEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack)
    }
}

extension EarthAndMoonViewController {
//    override var shouldAutorotate: Bool {
//        return self
//    }
}
