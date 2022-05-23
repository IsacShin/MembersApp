//
//  CustomGrabberHandleView.swift
//  app
//
//  Created by 신이삭 on 2021/05/31.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CustomGrabberHandleView:UIView {
    @IBOutlet weak var handleView: UIView!
    var btnHandler:(() -> Void)?
    
    static func initView(_ view:UIView, btnHandler:(() -> Void)?) -> CustomGrabberHandleView {
        
        let customView = UINib(nibName: "CustomGrabberHandleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomGrabberHandleView
        view.addSubview(customView)
        customView.handleView.layer.cornerRadius = 3
        customView.clipsToBounds = true
        customView.snp.makeConstraints { m in
            m.top.left.right.equalTo(view)
            m.height.equalTo(30)
        }

        // 초기화
        
        customView.btnHandler = btnHandler
        
        
        return customView
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        if let handler = self.btnHandler {
            handler()
        }
    }
}
