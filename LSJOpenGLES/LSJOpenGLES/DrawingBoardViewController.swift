//
//  DrawingBoardViewController.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/13.
//

import UIKit

class DrawingBoardViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view = DrawingBoardView.init(frame: view.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
