//
//  CommonAlert.swift
//  app
//
//  Created by isac on 2021/01/27.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

class CommonAlert {
    
    ////////////////////////// 공통 //////////////////////////
    // MARK: - 뷰 컨트롤러 생명주기
    
    /// 공통얼럿 : 버튼 1개 타입
    static func showAlertType1(vc:UIViewController, title:String = "", message:String = "", completeTitle:String = "확인", _ completeHandler:(() -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle:UIAlertController.Style.alert)
        let action1 = UIAlertAction(title:completeTitle, style: .default) { action in
            completeHandler?()
        }
        alert.addAction(action1)
        vc.present(alert, animated: true, completion: nil)
    }
    
    /// 공통얼럿 : 버튼 2개 타입
    static func showAlertType2(vc:UIViewController, title:String = "", message:String = "", cancelTitle:String = "취소", completeTitle:String = "확인",  _ cancelHandler:(() -> Void)? = nil, _ completeHandler:(() -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle:UIAlertController.Style.alert)
        let action1 = UIAlertAction(title:cancelTitle, style: .cancel) { action in
            cancelHandler?()
        }
        let action2 = UIAlertAction(title:completeTitle, style: .default) { action in
            completeHandler?()
        }
        alert.addAction(action1)
        alert.addAction(action2)
        vc.present(alert, animated: true, completion: nil)
    }
}
