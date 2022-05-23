//
//  UIDeviceExt.swift
//  app
//
//  Created by 신이삭 on 2021/06/29.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            if UIApplication.shared.windows.count == 0 { return false }
            let top = UIApplication.shared.windows[0].safeAreaInsets.top
            return top > 20
        } else {
            return false
        }
    }
}
