//
//  HttpConfig.swift
//  app
//
//  Created by 신이삭 on 2021/04/23.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit
import Hex

// MARK: - MENU TAB
enum MenuConfig: Int {
    case MemberVC = 0
    case CalendarVC
    case StatusVC
    case SettingVC
}

enum FooterConfig: Int {
    case Menu1 = 0
    case Menu2
    case Menu3
    case Menu4
}

// MARK: - HTTP
let CHTP = CommonHttp.shared

// MARK: - USERDEFAULT
let UDF = UserDefaults.standard

// MARK: - UI
let SCREEN_WIDTH                = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT               = UIScreen.main.bounds.size.height
var SAFEAREA_TOP: CGFloat {
    if #available(iOS 11.0, *) {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.top
        }
    } else {
        return UIApplication.shared.statusBarFrame.size.height
    }
    return 0.0
}

let uuidStr = UIDevice.current.identifierForVendor?.uuidString ?? ""

var SAFEAREA_BOTTOM: CGFloat {
    if #available(iOS 11.0, *) {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.safeAreaInsets.bottom
        }
    }
    return 0.0
}

let TABBAR_HEIGHT: CGFloat          = 60.0 + SAFEAREA_BOTTOM

// MARK: - MAIN COLOR
let COLOR_PURPLE = UIColor(hex: "A397DA")
let COLOR_MINT = UIColor(hex: "C3DBBF")
let COLOR_IBORY = UIColor(hex: "EAE6DF")
let COLOR_BASY  = UIColor(hex: "F5F5DC")
