//
//  CommonNav.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

class CommonNav:NSObject {
    static func moveMainVC() {
        let vc = Utils.getVC(storyBoard: "Main", controller: "MainVC") as! MainVC
        
        if let appD = UIApplication.shared.delegate as? AppDelegate {
            let transition: CATransition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            appD.navigationVC?.view.layer.add(transition, forKey: nil)
            appD.navigationVC?.setViewControllers([vc], animated: false)
        }
    }
    
    // modalType : base - 기본 푸쉬 애니메이션 / modal - 푸시 지만 모달 형식에 애니메이션
    static func moveBaseWebVC(_ url: String, _ titleStr: String? = nil, _ modalType:modalType = .base) {

        let vc = Utils.getVC(storyBoard: "Base", controller: "BaseWebVC") as! BaseWebVC
        
        vc.mbilUrl = url
        vc.titleStr = titleStr
        vc.webViewType = modalType
        if let appD = UIApplication.shared.delegate as? AppDelegate {
            if let naviVC = appD.navigationVC {
                if modalType == .modal {
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromTop
                    
                    naviVC.view.layer.add(transition, forKey: kCATransition)
                    naviVC.pushViewController(vc, animated: false)
                }else {
                    naviVC.pushViewController(vc, animated: true)
                }
                
                
            }
            
        }
    }
    
    static func movePermissionVC(parentVC:UIViewController) {
        let vc = Utils.getVC(storyBoard: "Permission", controller: "PermissionVC") as! PermissionVC
        vc.modalPresentationStyle = .overCurrentContext

        parentVC.present(vc, animated: false) {}
    }
    
    static func moveEditDateVC(parentVC:UIViewController) {
        let vc = Utils.getVC(storyBoard: "Calendar", controller: "EditDateVC") as! EditDateVC
        vc.parentVC = parentVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.alpha = 0
        parentVC.present(vc, animated: false) {}
    }
    
    static func moveTutorialVC(parentVC:UIViewController, _ anim:Bool = false) {
        let vc = Utils.getVC(storyBoard: "Tutorial", controller: "TutorialVC") as! TutorialVC

        vc.parentVC = parentVC
        if let appD = UIApplication.shared.delegate as? AppDelegate {
            if let naviVC = appD.navigationVC {
                naviVC.pushViewController(vc, animated: anim)
            }
            
        }
    }
    
    static func moveCalendarVC() {
        let vc = Utils.getVC(storyBoard: "Calendar", controller: "CalendarVC") as! CalendarVC

        if let appD = UIApplication.shared.delegate as? AppDelegate {
            if let naviVC = appD.navigationVC {
                naviVC.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    static func moveAddMembersVC(_ vcType:VCType = .add, _ stdIdx:String? = nil) {
        let vc = Utils.getVC(storyBoard: "Main", controller: "AddMembersVC") as! AddMembersVC
        
        vc.vcType = vcType
        vc.stdIdx = stdIdx
        
        if let appD = UIApplication.shared.delegate as? AppDelegate {
            if let naviVC = appD.navigationVC {
                naviVC.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    static func moveFeedbackVC() {
        let vc = Utils.getVC(storyBoard: "Main", controller: "FeedbackVC") as! FeedbackVC
        
        if let appD = UIApplication.shared.delegate as? AppDelegate {
            if let naviVC = appD.navigationVC {
                naviVC.pushViewController(vc, animated: true)
            }
            
        }
    }
}
