//
//  Utils.swift
//  app
//
//  Created by 신이삭 on 2021/03/02.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

class Utils:NSObject {
    /// Storyboard에서 특정 ViewController를 반환
    /// - Parameter strSBName: Storyboard 이름
    /// - Parameter strControllerName: ViewController 이름
    /// - Returns: 해당 ViewController. 없으면 nil
    static func getVC(storyBoard strSBName: String, controller strControllerName: String) -> UIViewController? {
        let str: String? = strSBName
        if (strSBName == "" || str == nil) {
            return nil
        }
        
        let str2: String? = strControllerName
        if (strControllerName == "" || str2 == nil) {
            return nil
        }

        let storyboard = UIStoryboard(name: strSBName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: strControllerName)
        return vc
    }
    
    
    /// 업데이트 여부 체크
    /// - Returns: false일 경우 최신버전
    static func isUpdateAvailable() -> Bool {
        
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=내번들ID"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
        
        else { return false }
        
        if !(version == appStoreVersion) { return true }
        
        else{ return false }
 
    }

}
