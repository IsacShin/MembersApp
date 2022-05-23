//
//  ViewController.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class MainVC: BaseVC {

    @IBOutlet weak var containerView: UIView!
    
    var footerView: FooterMenuView?
    var viewControllers: [BaseVC]!
    
    var menuVC: BaseVC!
    
    var memberVC: MembersVC!
    var calendarVC: CalendarVC!
    var alarmVC: AlarmVC!
    var settingVC: SettingVC!
    
    

    // 현재 사용자가 보고있는 Footer Index
    var currentIndex: Int = MenuConfig.MemberVC.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMenus()
        self.initFooterView()
        
        self.moveToMenu(MenuConfig.MemberVC.rawValue)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
    func initMenus(){
        self.memberVC     = Utils.getVC(storyBoard: "Main", controller: "MembersVC") as? MembersVC
        self.calendarVC   = Utils.getVC(storyBoard: "Calendar", controller: "CalendarVC") as? CalendarVC
        self.alarmVC     = Utils.getVC(storyBoard: "Main", controller: "AlarmVC") as? AlarmVC
        self.settingVC     = Utils.getVC(storyBoard: "Main", controller: "SettingVC") as? SettingVC
        self.viewControllers = [self.memberVC,self.calendarVC,self.alarmVC,self.settingVC]
        
        //self.moveToController(self.homeVC)
    }
    
    /// 메뉴 Footer 생성 및 초기화
    func initFooterView() {
        self.footerView = FooterMenuView.initView(self.view, menuBtnHandler: { (index) in
            
            self.moveToMenu(index)
        })
    }
    
    func moveToMenu(_ index: Int) {
        
        self.currentIndex = index
        
        let vc = self.viewControllers[index]
        if vc == self.menuVC {
            return
        }
  
        self.moveToController(vc)
        
        
        self.footerView?.animIndicatorBar(index)
    }
    
    func moveToController(_ vc: BaseVC) {
        self.removeChildView()
        
        self.menuVC = vc
        self.addChild(self.menuVC)
        self.menuVC.view.frame = self.containerView.frame
        self.containerView.addSubview(self.menuVC.view)
        self.menuVC.didMove(toParent: self)
        vc.initView()
        
        self.view.layoutIfNeeded()
    }

    /// 메인 컨트롤러에 연결되어 있는, Child 컨트롤러 Remove
    func removeChildView() {
        if let vc = self.menuVC {
            self.menuVC = nil
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }

}


extension MainVC {
    /// Footer가 슬라이드 Up되면서 나타나는 애니메이션
    func animShowFooter(){
        self.footerView?.showFooter()
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    /// Footer가 슬라이드 Down되면서 사라지는 애니메이션
    func animHideFooter(){
        self.footerView?.hideFooter()
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
