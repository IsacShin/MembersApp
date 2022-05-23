//
//  PermissionVC.swift
//  app
//
//  Created by 신이삭 on 2021/06/12.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class PermissionVC: UIViewController,AdsProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
    }
    
    @IBAction func btnClosePressed(_ sender: Any) {
        self.popAnimVC {}
    }
    
    
    @IBAction func btnAccessPressed(_ sender: Any) {
        self.popAnimVC {}
        
    }

}

extension PermissionVC {
    func popAnimVC(completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 0
        } completion: { finished in
            self.dismiss(animated: false) {
    //            // 날짜 정보 저장
    //            let dateFormatter = DateFormatter()
    //            dateFormatter.dateFormat = "yyyy.MM.dd"
    //            dateFormatter.locale = Locale(identifier: "ko_KR")
    //            let timeStr = dateFormatter.string(from: Date())
    //
    //            UserDefaults.standard.set(timeStr, forKey: "mapTutorialDate")
            }
        }

    }
}
