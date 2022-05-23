//
//  HomeVC.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class HomeVC: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            if #available(iOS 11.0, *) {
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: footerInset, right: 0)
                self.scrollView.contentInsetAdjustmentBehavior = .never
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func postDate() {
        CHTP.getTestAPI(vc: self) { (result) in
            let headers = result["headers"]
            print(headers["Accept"])
            print(headers["Accept-Language"])
            print(headers["Accept-Encoding"])
        }
    }

    @IBAction func testBtnPressed(_ sender: Any) {
        CommonNav.moveBaseWebVC("https://www.apple.com/", "상세페이지", .modal)
    }
    @IBAction func pressBtnModalWeb(_ sender: Any) {
        //CommonNav.moveBaseWebVC("https://www.apple.com/", "상세페이지", .modal)
        CommonNav.moveCalendarVC()
    }
}
