//
//  GLSLViewController.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/10.
//

import UIKit

class GLSLViewController: UIViewController {

    var glslView: GLSLView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let kview = self.view as! GLKView
        
        glslView = GLSLView.init(frame: self.view.bounds)// = self.view as! GLSLView
        self.view.addSubview(self.glslView!)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
