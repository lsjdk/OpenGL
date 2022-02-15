//
//  DrawingBoardView.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/13.
//

import UIKit
import GLKit

enum Programs: Int {
    case point = 0
    case num
}

struct TextureInfo_t {
    var id: GLuint?
    var width: Int?
    var height: Int?
}

struct programInfo_t {
    var vert: String?
    var frag: String?
    var uniform: [GLint]?
    var id: GLuint?
}

class DrawingBoardView: UIView {

    private var myContext: EAGLContext?
    private var myLayer: CAEAGLLayer?
    private var viewRenderBuffer: GLuint = 0
    private var viewFrameBuffer: GLuint = 0
    
    private var backingWidth: GLint = 0
    private var backingHeight: GLint = 0
    
    private var vertexBuffer: GLuint = 0
    private var brushTexture: TextureInfo_t?
    
    private var program: [programInfo_t] = [programInfo_t.init(vert: "point.vsh", frag: "point.fsh", uniform: nil, id: nil)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initViewFromNib()
        fatalError("init(coder:) has not been implemented")
    }
}




extension DrawingBoardView {
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    func initViewFromNib() {
        self.backgroundColor = .green
        self.setUplayerAndContext()
        self.getInitData()
    }
}

extension DrawingBoardView {
    func initGL() -> Void {
        glGenRenderbuffers(1, &self.viewRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.viewRenderBuffer)
        
        glGenFramebuffers(1, &self.viewFrameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.viewFrameBuffer)
        
        self.myContext?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.myLayer)
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.viewRenderBuffer)
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &self.backingWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &self.backingHeight)
        
        guard glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GL_FRAMEBUFFER_COMPLETE else {
            return
        }
        
        
        glViewport(0, 0, backingWidth, backingHeight)
        
        glGenBuffers(1, &self.vertexBuffer)
        
        self.brushTexture = self.textrue(Frome: "Particle.png")
        
        self.setupShaders()
        
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
    }
    func setUplayerAndContext() -> Void {
        guard let layer = self.layer as? CAEAGLLayer else {
            return
        }
        self.myLayer = layer
        self.contentScaleFactor = UIScreen.main.scale
        layer.isOpaque = true
        layer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,
                                         kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                    ]
        if let context = EAGLContext.init(api: .openGLES3), EAGLContext.setCurrent(context) {
            self.myContext = context
        }else {
            print("====context:设置失败===")
        }
    }
}

extension DrawingBoardView {
    
    func setupShaders() {
        guard let vertexFile = Bundle.main.path(forResource: "DrawingBoardShaderV", ofType: "glsl"), let fragmentFile = Bundle.main.path(forResource: "DrawingBoardShaderF", ofType: "glsl") else {
            return
        }
        
        var myPrograme = GLSLManager.loadProgram(vertexPath: vertexFile, fragmentPath: fragmentFile)
        if myPrograme == 0 {
            print("-=-Program Link Failed!=-=-=")
            return
        }
        print("-=-Program Link Success!=-=-=")
        
        glUseProgram(myPrograme)
    }
    
    func textrue(Frome name: String) -> TextureInfo_t? {
       
        guard let cgimage = UIImage.init(named: name)?.cgImage else {
            return nil
        }
        let width = cgimage.width
        let height = cgimage.height
        
        var spriteData = [GLubyte](repeating: 0, count: width * height * 4 * MemoryLayout<GLubyte>.size)
        
        let context = CGContext.init(data: &spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: cgimage.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
        context?.draw(cgimage, in: rect)
        
        var texid: GLuint = 0
        
        glGenTextures(1, &texid)
        glBindTexture(GLenum(GL_TEXTURE_2D), texid)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINES)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
        
        free(&spriteData)
        
        let texture = TextureInfo_t.init(id: texid, width: width, height: height)
        
        return texture
    }
}

extension DrawingBoardView {
    func getInitData() {
        guard let path = Bundle.main.path(forResource: "abc", ofType: "string") else {
            print("Get path failed")
            return
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data.init(contentsOf: url),
              let string = String(data: data, encoding: String.Encoding.utf8),
              let dataArray = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: []) as? [[String: Any]]
        else {
            print("Data create failed")
            return
        }
        let pointArray = dataArray.compactMap { dic -> CGPoint? in
            guard let mx = dic["mX"] as? CGFloat, let my = dic["mY"] as? CGFloat else {
                return nil
            }
            return CGPoint.init(x: mx, y: my)
        }
    }
}
