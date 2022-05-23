//
//  IntroVC.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import Lottie

class IntroVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COLOR_PURPLE
        startAnim()
    }
    
    
    func startAnim() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) {
            UIView.animate(withDuration: 1.5) {

            } completion: { f in
                UIView.animate(withDuration: 1.0, animations: {
                
                }) { (finished) in
                    
                    CommonNav.moveMainVC()
                }
            }
        }
    }

}
