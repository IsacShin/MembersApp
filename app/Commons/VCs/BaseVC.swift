//
//  BaseVC.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class BaseVC: UIViewController {
    
    /// 공통 > 화면 초기화
    func initView(){}
    
    var statusBarShouldBeHidden = false
    
    var footerInset: CGFloat {
        let FooterHeight: CGFloat = 60
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = (window?.safeAreaInsets.bottom) ?? 0
            return bottomPadding + FooterHeight
        } else {
            return bottomLayoutGuide.length + FooterHeight
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "HH:mm"
        
        return formatter
    }()
    
    var memberVcInitAnim = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default //.default for black style
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 자동으로 스크롤뷰 인셋 조정하는 코드 막기
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // self.navigationController?.heroNavigationAnimationType = .push(direction: .left)
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    // 시간차이
    func intervalTime(end: Date, start: Date) -> TimeInterval {
        return end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
    }
    
    // 날짜비교
    func compareDays(startDate:String, endDate:String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from:startDate)!
        let endDate = dateFormatter.date(from:endDate)!

        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        print("\(days)일만큼 차이납니다.")
        return days
    }
    
    // 상태바 숨기기
    func hideStatusAnim() {
        self.statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    // 상태바 보이기
    func showStatusAnim() {
        self.statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // 이미지 리사이징
    func resizeTopAlignedToFill(originImg: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / originImg.size.width
        let newHeight = originImg.size.height
        
        let newSize = CGSize(width: newWidth, height: newHeight * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        originImg.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func openUrl(_ urlString: String, _ handler:(() -> Void)? = nil) {
        
        if urlString.hasPrefix("kakaolink") {
            guard let url = URL(string: urlString) else {
                return //be safe
            }
            print("url : \(url)")
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (result) in
                    handler?()
                }
                
            } else {
                UIApplication.shared.openURL(url)
                handler?()
            }
        } else {
            // 퍼센트 인코딩
            var percentEncoding = CharacterSet.urlQueryAllowed
            percentEncoding.insert(charactersIn: "#")
            
            if let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: percentEncoding) {
                guard let url = URL(string: encodingUrl) else {
                    return //be safe
                }
                print("url : \(url)")
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:]) { (result) in
                        handler?()
                    }
                    
                } else {
                    UIApplication.shared.openURL(url)
                    handler?()
                }
            }
        }
    }
    
    func closeVC() {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        
        navigationController?.view.layer.add(transition, forKey:kCATransition)
        let _ = navigationController?.popViewController(animated: false)
    }
}
