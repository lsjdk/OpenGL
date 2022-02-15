//
//  ViewController.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/9.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton.init()
        button.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside);
        self.view.addSubview(button)
        
        // Do any additional setup after loading the view.
        
        
    }

    @objc func buttonClick(_ sender: Any) {
        let vc = EarthAndMoonViewController.init()
//        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

