//
//  SettingVC.swift
//  app
//
//  Created by 신이삭 on 2021/06/13.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class SettingVC: BaseVC {

    @IBOutlet weak var versionStr: UILabel!
    var updateCheck:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        compareVersion()
    }
    
    func compareVersion() {
        // 현재버전 정보 가져오기
        let currentAppVer = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        // 배포 시 버전 수정 필요
        let url = "https://itunes.apple.com/lookup?id=1506465721"
        let apiURI : URL! = URL(string: url)
        let apidata = try! Data(contentsOf: apiURI)
        var resultVersion:String?
        
        do{
            let apiDict =
                try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            let results = apiDict["results"] as! NSArray
            for row in results{
                let imsi = row as! NSDictionary
                resultVersion = (imsi["version"] as? String)!
            }
            
        }catch{
            print("파싱 예외 발생")
        }
        
        if let updateVer = resultVersion {
            switch currentAppVer.compare(updateVer) {
                case .orderedAscending:
                    self.updateCheck = true
                    self.versionStr.text = "ver \(currentAppVer) 업데이트가 필요한 버전입니다."
                    return
                case .orderedSame:
                    self.versionStr.text = "ver \(currentAppVer) 현재 최신버전 입니다."
                    break
                case .orderedDescending:
                    break
            }
        }
        
    }
}

extension SettingVC {
    
    @IBAction func moveAlarimSetting(_ sender: Any) {
        self.openUrl(UIApplication.openSettingsURLString) {}
    }
    
    @IBAction func moveTutorial(_ sender: Any) {
        CommonNav.moveTutorialVC(parentVC: self, true)
    }
    
    @IBAction func moveFeedBack(_ sender: Any) {
        CommonNav.moveFeedbackVC()
    }
    
    @IBAction func moveAppstore(_ sender: Any) {
        if updateCheck {
            self.openUrl("itms-apps://itunes.apple.com/app/1506465721", { () -> (Void) in
                exit(0)
            })
        }
    }
}
