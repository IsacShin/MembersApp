//
//  AppDelegate.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationVC: BaseNaviVC?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        self.initNavigationVC()
        
        return true
    }
    
    /*
     Type1 ::: 커스텀 탭바를 사용할 시 원하는 탭 높이 조정가능 및 아이콘 이미지 타이틀 커스텀을 원할경우 사용
     */
    func initNavigationVC() {
        
        self.navigationVC = BaseNaviVC()
        self.navigationVC?.isNavigationBarHidden = true
        self.navigationVC?.interactivePopGestureRecognizer?.isEnabled = true
        
        let introVC = Utils.getVC(storyBoard: "Intro", controller: "IntroVC") as! IntroVC
        self.navigationVC?.setViewControllers([introVC], animated: false)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = self.navigationVC
        self.window!.makeKeyAndVisible()
    }
    
    //스킴으로 들어올시
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        if let _ = self.navigationVC?.viewControllers.first as? MainVC {
            let urlStr = "\(url)"
            self.moveScheme(scheme: urlStr)
            return true
        }
        else {
            
        }

        return false

    }
    
    // didRegisterForRemoteNotificationsWithDeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
        print("디바이스 토큰값 : "+deviceTokenString)
       
    }
    
    // didReceiveRemoteNotification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]){
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        // 푸시정보
        var pushList  = UDF.object(forKey: "pushList") as? [[String : Any]] ?? [[String:Any]]()
        
        if pushList.count > 0 {
            for (_, item) in pushList.enumerated() {
                if let alert = item["alert"] as? [String:Any] {
                    if let title = alert["title"] as? String {
                        if let body = alert["body"] as? String {
                            pushList.append([
                                "date" : title,
                                "comment" : body
                            ])
                        }
                    }
                }
            }
        }else {
            if let aps = userInfo["aps"] as? [String:Any] {
                if let alert = aps["alert"] as? [String:Any] {
                    if let title = alert["title"] as? String {
                        if let body = alert["body"] as? String {
                            pushList.append([
                                "date" : title,
                                "comment" : body
                            ])
                        }
                    }
                }
            }
            
        }
        
        
        print(pushList)
        UDF.set(pushList, forKey: "pushList")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let appD = UIApplication.shared.delegate as? AppDelegate {
            if let _ = appD.navigationVC?.viewControllers.first as? MainVC {
                
            }
        }
    }
}

extension AppDelegate {
    
    /*
        스킴 외부접근 시 사용
     */
    func moveScheme(scheme: String) {
        var fixedScheme = scheme

        let schemes = fixedScheme.components(separatedBy: "kakaolink?")
        if schemes.count > 1 {
            fixedScheme = schemes.last ?? ""
        }

        var type = ""
        if let page = getQueryStringParameter(url: fixedScheme, param: "page") { //스킴 명칭
            type = page
        }else{
            type = fixedScheme
        }

        switch type.uppercased() {
        case "" : //스킴 String
            break
       
        default :
            break
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value?.removingPercentEncoding
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function)")
        completionHandler([.alert, .sound, .badge])
    }
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("Firebase registration token: \(token)")
            let dataDict:[String: String] = ["token": token]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
    }
    
}
