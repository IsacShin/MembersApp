//
//  UINaviControllerExt.swift
//  app
//
//  Created by 신이삭 on 2021/06/17.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func popViewControllerWithHandler(animated:Bool = false, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
    func pushViewController(viewController: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}
