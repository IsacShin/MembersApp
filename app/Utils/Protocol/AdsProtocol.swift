//
//  AdsProtocol.swift
//  app
//
//  Created by 신이삭 on 2021/05/10.
//  Copyright © 2021 isac. All rights reserved.
//

import AppTrackingTransparency
import AdSupport

public protocol AdsProtocol {
    //IDFA 값
    var idfa: UUID { get }
    
    //추적 권한 팝업 요청 메소드
    func checkTrackingIDFA(completion: ((String)-> Void)?)
}

public extension AdsProtocol {
    
    var idfa: UUID {
        return ASIdentifierManager.shared().advertisingIdentifier
    }
    
    func checkTrackingIDFA(completion: ((String)-> Void)? = nil) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .authorized:
                    print("광고추적 허용")
                    print("IDFA: ", self.idfa)
                    completion?(self.idfa.uuidString)
                case .denied, .notDetermined, .restricted:
                    print("광고추적 비허용")
                    print("IDFA: ", self.idfa)
                    completion?(self.idfa.uuidString)
                @unknown default:
                    print("UNKNOWN")
                    print("IDFA: ", self.idfa)
                    completion?(self.idfa.uuidString)
                }
            }
        } else {
            print("Under 14.0")
            print("IDFA: ", self.idfa)
            completion?(self.idfa.uuidString)
        }

    }
}
