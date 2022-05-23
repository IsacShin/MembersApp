//
//  FooterView.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FooterView: UIView {
    let Anim_Duration:Double = 0.2
    var footerHeight:CGFloat!
    
    func initConstraint() {
        if let parentVC = self.parentViewController() as? BaseVC {
            self.footerHeight = parentVC.footerInset
        }else if let webVC = self.parentViewController() as? BaseWebVC {
            self.footerHeight = webVC.footerInset
        }else {
            self.footerHeight = (self.parentViewController() as? BaseVC)?.footerInset ?? 60
        }
    }
    
}


extension FooterView {
    // FooterView Animation
    func hideFooterAnim(completion: @escaping ()->()) {
        self.hideFooter()
        UIView.animate(withDuration: Anim_Duration, animations: {
            self.superview!.layoutIfNeeded()
        }) { (finished) in
            completion()
        }
    }
    
    func showFooterAnim(completion: @escaping ()->()) {
        self.showFooter()
        UIView.animate(withDuration: Anim_Duration, animations: {
            self.superview!.layoutIfNeeded()
        }) { (finished) in
            completion()
        }
    }
    
    
    func hideFooter() {
        self.snp.remakeConstraints { (make) in
            make.left.right.equalTo(self.superview!)
            make.bottom.equalTo(self.superview!).offset(self.footerHeight)
            make.height.equalTo(self.footerHeight)
        }
    }
    
    func showFooter() {
        self.snp.remakeConstraints { (make) in
            make.left.right.equalTo(self.superview!)
            make.bottom.equalTo(self.superview!).offset(0)
            make.height.equalTo(self.footerHeight)
        }
    }
}
