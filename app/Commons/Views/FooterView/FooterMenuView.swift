//
//  FooterMenuView.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FooterMenuView:FooterView {
    @IBOutlet weak var menuStackView: UIStackView!
    
    var indicatorBar:UIView?
    var menuBtnHandler:((Int) -> Void)?
    
    // 공통푸터 생성
    static func initView(_ view:UIView, menuBtnHandler:((Int) -> Void)?) -> FooterMenuView {
        
        let footer = UINib(nibName: "FooterMenuView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FooterMenuView
        view.addSubview(footer)

        // 초기화
        footer.initConstraint()
        footer.showFooter()
        
        footer.initIndicatorBar()
        
        footer.menuBtnHandler = menuBtnHandler
        
        
        return footer
    }
    
    
    func initIndicatorBar() {
        self.indicatorBar = UIView()

        if let indicatorBar = self.indicatorBar {
            indicatorBar.backgroundColor = COLOR_PURPLE
            self.addSubview(indicatorBar)
            
            indicatorBar.snp.makeConstraints { (make) in
                make.top.equalTo(self)
                make.left.right.equalTo(self.menuStackView.subviews[FooterConfig.Menu1.rawValue])
                make.height.equalTo(3)
            }
        }
    }
    
    //1
    @IBAction func btnMenu1Pressed(_ sender: Any) {
        if let handler = self.menuBtnHandler {
            guard let button = sender as? UIButton else {
                return
            }
            handler(button.tag)
        }

    }
    
    //2
    @IBAction func btnMenu2Pressed(_ sender: Any) {
        if let handler = self.menuBtnHandler {
            guard let button = sender as? UIButton else {
                return
            }
            handler(button.tag)
        }

    }
    
    //3
    @IBAction func btnMenu3Pressed(_ sender: Any) {
        if let handler = self.menuBtnHandler {
            guard let button = sender as? UIButton else {
                return
            }
            handler(button.tag)
        }

    }
    
    //4
    @IBAction func btnMenu4Pressed(_ sender: Any) {
        if let handler = self.menuBtnHandler {
            guard let button = sender as? UIButton else {
                return
            }
            handler(button.tag)
        }

    }
    
}

extension FooterMenuView {
    /// 인디케이터 애니메이션
    func animIndicatorBar(_ index: Int, isAnim:Bool = true) {
        if isAnim == true {
            self.indicatorBar?.snp.remakeConstraints { (make) in
                make.top.equalTo(self)
                make.left.right.equalTo(self.menuStackView.subviews[index])
                make.height.equalTo(3)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        } else {
            self.indicatorBar?.snp.remakeConstraints { (make) in
                make.top.equalTo(self)
                make.left.right.equalTo(self.menuStackView.subviews[index])
                make.height.equalTo(3)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension FooterMenuView: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y > 0) {
            self.hideFooterAnim {}
        }else{
            self.showFooterAnim {}
        }
    }
}
