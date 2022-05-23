//
//  FooterCloseView.swift
//  app
//
//  Created by 신이삭 on 2021/05/27.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

class FooterCloseView:FooterView {
    
    var closeHandler:(() -> Void)?
    weak var scrollView:UIScrollView?
    var isHideFooter: Bool = false
    
    // 공통푸터 생성
    static func initView(_ view:UIView, _ scrollView:UIScrollView? = nil, handler:(() -> Void)? = nil) -> FooterCloseView {
        
        let footer = UINib(nibName: "FooterCloseView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FooterCloseView
        view.addSubview(footer)
        
        footer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 124, alpha: 1)
        
        // 초기화
        footer.initConstraint()
        footer.showFooter()
        
        footer.closeHandler = handler
        
        footer.scrollView = scrollView
        scrollView?.delegate = footer
        
        
        return footer
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        if let handler = closeHandler {
            handler()
        }
    }
    
}


//// MARK: - UIScrollViewDelegate
extension FooterCloseView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y > 0) {
            
            self.isHideFooter = true
            
            self.hideFooterAnim {}

        }
        else{
            
            self.isHideFooter = false
            
            self.showFooterAnim {}

        }
    }
}
