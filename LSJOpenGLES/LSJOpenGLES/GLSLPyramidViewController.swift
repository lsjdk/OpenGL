//
//  GLSLPyramidViewController.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/13.
//

import UIKit
import GLKit


class GLSLPyramidViewController: GLKViewController {
    
    var myEffect: GLKBaseEffect?
    
    var XB: Bool = false
    var YB: Bool = false
    var ZB: Bool = false
    
    var XDegree: Float = 0
    var YDegree: Float = 0
    var ZDegree: Float = 0
    
    var indices: [GLuint] = [
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3
    ]
    
    private var timer: DispatchSourceTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpContext()
        self.renderView()
        
        self.createButton()
        self.addTimer()
    }
    deinit {
        self.timer?.cancel()
    }
}


extension GLSLPyramidViewController {
    func renderView() -> Void {
        //顶点数据
        let attrArr: [GLfloat] = [
            -0.5, 0.5, 0.0,       0.0, 0.0, 0.5,             0.0, 1.0,//左上
             0.5, 0.5, 0.0,       0.0, 0.5, 0.0,             1.0, 1.0,//右上
             -0.5, -0.5, 0.0,     0.5, 0.0, 1.0,             0.0, 0.0,//左下
             0.5, -0.5, 0.0,      0.0, 0.0, 0.5,             1.0, 0.0,//右下
             0.0, 0.0, 1.0,       1.0, 1.0, 1.0,             0.5, 0.5 //顶点
        ]
        //缓存顶点数据
        var arrayBuffer: GLuint = 0
        glGenBuffers(1, &arrayBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), arrayBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), attrArr.count * MemoryLayout<GLfloat>.size, attrArr, GLenum(GL_STATIC_DRAW))
        
        
        //缓存顶点索引数据
        var indexBuffer: GLuint = 0
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indices.count * MemoryLayout<GLuint>.size, self.indices, GLenum(GL_STATIC_DRAW))
        
        
        //使用顶点数据
        //顶点
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 8, UnsafeRawPointer.init(bitPattern: 0))
        //        颜色
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 8, UnsafeRawPointer.init(bitPattern: 3 * (MemoryLayout<GLfloat>.size)))
        //        纹理
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), Int32(MemoryLayout<GLfloat>.size) * 8, UnsafeRawPointer.init(bitPattern: 6 * (MemoryLayout<GLfloat>.size)))
        
        guard let path = Bundle.main.path(forResource: "cTest", ofType: "jpg") else {
            return
        }
        
        let option = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: 1)]
        
        guard let textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: path, options: option) else {
            return
        }
        self.myEffect = GLKBaseEffect.init()
        self.myEffect?.texture2d0.enabled = GLboolean(GL_TRUE)
        self.myEffect?.texture2d0.name = textureInfo.name
        
        //        设置投影矩阵
        
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), Float(self.view.frame.size.width / self.view.frame.size.height), 0.1, 10)
        
        self.myEffect?.transform.projectionMatrix = projectionMatrix
        
        var modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2)
        
        self.myEffect?.transform.modelviewMatrix = modelViewMatrix
    }
}
extension GLSLPyramidViewController {
    func setUpContext() {
        self.delegate = self
        guard let context = EAGLContext.init(api: .openGLES3) else {
            return
        }
        let kView: GLKView = self.view as! GLKView
        kView.context = context
        
        kView.drawableColorFormat = .RGBA8888
        kView.drawableDepthFormat = .format24
        EAGLContext.setCurrent(context)
        glEnable(GLenum(GL_DEPTH_TEST))
    }
}

extension GLSLPyramidViewController {
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        super.glkView(view, drawIn: rect)
        glClearColor(0.3, 0.3, 0.3, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        self.myEffect?.prepareToDraw()
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
    }
}

extension GLSLPyramidViewController: GLKViewControllerDelegate {
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        var modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2)
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree)
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.YDegree)
        modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.ZDegree)
        self.myEffect?.transform.modelviewMatrix = modelViewMatrix
    }
}
extension GLSLPyramidViewController {
    func addTimer() {
        // 子线程创建timer
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        //        let timer = DispatchSource.makeTimerSource()
        /*
         dealine: 开始执行时间
         repeating: 重复时间间隔
         leeway: 时间精度
         */
        timer?.schedule(deadline: .now(), repeating: DispatchTimeInterval.milliseconds(100), leeway: DispatchTimeInterval.seconds(0))
        // timer 添加事件
        timer?.setEventHandler {
            print("timer事件")
            self.XDegree += self.XB ? 0.1 : 0
            self.YDegree += self.YB ? 0.1 : 0
            self.ZDegree += self.ZB ? 0.1 : 0
        }
        timer?.resume()
    }
    func createButton() {
        let xbutton = UIButton.init()
        xbutton.backgroundColor = UIColor.red
        xbutton.setTitle("X", for: .normal)
        xbutton.addTarget(self, action: #selector(xbuttonClick(_:)), for: .touchUpInside);
        self.view.addSubview(xbutton)
        
        let ybutton = UIButton.init()
        ybutton.backgroundColor = UIColor.red
        ybutton.setTitle("Y", for: .normal)
        ybutton.addTarget(self, action: #selector(ybuttonClick(_:)), for: .touchUpInside);
        self.view.addSubview(ybutton)
        
        let zbutton = UIButton.init()
        zbutton.backgroundColor = UIColor.red
        zbutton.setTitle("Z", for: .normal)
        zbutton.addTarget(self, action: #selector(zbuttonClick(_:)), for: .touchUpInside);
        self.view.addSubview(zbutton)
        let width = self.view.bounds.size.width
        let height = self.view.bounds.size.height
        ybutton.frame = CGRect.init(x: (width - 50) / 2, y: height - 200, width: 50, height: 50)
        xbutton.frame = CGRect.init(x: (width - 50) / 2 - 100, y: height - 200, width: 50, height: 50)
        zbutton.frame = CGRect.init(x: (width - 50) / 2 + 100, y: height - 200, width: 50, height: 50)
    }
    @objc func xbuttonClick(_ sender: Any) -> Void {
        self.XB = !self.XB
    }
    @objc func ybuttonClick(_ sender: Any) -> Void {
        self.YB = !self.YB
    }
    @objc func zbuttonClick(_ sender: Any) -> Void {
        self.ZB = !self.ZB
    }
}
