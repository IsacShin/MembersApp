//
//  BaseNaviVC.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import Hero

class BaseNaviVC: UINavigationController {

    override func popViewController(animated: Bool) -> UIViewController? {
        
        if self.hero.isEnabled == true {
            
            self.viewControllers.last?.view.backgroundColor = .clear
        }
        
        return super.popViewController(animated: animated)
    }

}
