//
//  ChangeBackColor.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/9.
//

import UIKit
import GLKit

class ChangeBackColor: GLKViewController {

    var context: EAGLContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let kview: GLKView = self.view as! GLKView
        kview.delegate = self
//        view.addSubview(kview)
        
        context = EAGLContext.init(api: .openGLES3)
        
        kview.context = self.context!
//
        EAGLContext.setCurrent(kview.context)
//
//
//        kview.drawableDepthFormat = .format24
//
        glClearColor(1, 0.0, 0.0, 1)
    }
    
}

extension ChangeBackColor {
//    func glkViewControllerUpdate(_ controller: GLKViewController) {
//        <#code#>
//    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.1, 0.1, 0.1, 0.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_TEST))
    }
}
