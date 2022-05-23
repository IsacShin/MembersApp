//
//  TutorialVC.swift
//  app
//
//  Created by 신이삭 on 2021/05/27.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class TutorialVC: BaseVC {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    var parentVC:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bgView.backgroundColor = COLOR_PURPLE
        setPageControl()
        
        if let _ = parentVC as? MembersVC {
            CommonNav.movePermissionVC(parentVC: self)
        }
    }
    
    func setPageControl() {
        
        pageControl.pageIndicatorTintColor = UIColor(hex: "#dcdcdc")
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.backgroundColor = .clear
        pageControl.numberOfPages = 4

    }
        
}

extension TutorialVC {
    @IBAction func btnStartPressed(_ sender: Any) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewControllerWithHandler(animated: false, completion: {
            UDF.setValue(self.formatter.string(from: Date()), forKey: "TutorialDate")
        })
    }
}
